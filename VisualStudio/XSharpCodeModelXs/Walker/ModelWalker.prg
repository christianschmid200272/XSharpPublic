//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//

USING LanguageService.CodeAnalysis.XSharp.SyntaxParser
USING LanguageService.SyntaxTree
USING LanguageService.SyntaxTree.Misc
USING LanguageService.SyntaxTree.Tree
USING System
USING System.Collections.Generic
USING System.Diagnostics
USING System.Linq
USING System.Text
USING System.Threading
USING System.Threading.Tasks
USING System.Collections.Concurrent
USING XSharp.Parser
USING LanguageService.CodeAnalysis
USING LanguageService.CodeAnalysis.Text

BEGIN NAMESPACE XSharpModel
	CLASS ModelWalker IMPLEMENTS VsParser.IErrorListener
		// Fields
		PRIVATE _projects := ConcurrentQueue<XProject>{} AS ConcurrentQueue<XProject>
		PRIVATE _projectsForTypeResolution := ConcurrentQueue<XProject>{} AS ConcurrentQueue<XProject>
		STATIC PRIVATE _walker AS ModelWalker
		PRIVATE _WalkerThread AS System.Threading.Thread
		STATIC PRIVATE suspendLevel  AS LONG

		// Methods

		STATIC CONSTRUCTOR
			suspendLevel := 0

		PRIVATE  CONSTRUCTOR()
			SUPER()


		INTERNAL METHOD AddProject(xProject AS XProject) AS VOID
			//
			WriteOutputMessage("-->> AddProject() "+xProject:Name)
			BEGIN LOCK SELF
				//
				VAR lAdd2Queue := TRUE
				FOREACH project AS XProject IN SELF:_projects
					//
					IF (String.Equals(project:Name, xProject:Name, StringComparison.OrdinalIgnoreCase))
						//
						lAdd2Queue := FALSE
						EXIT

					ENDIF
				NEXT
				IF (lAdd2Queue)
					//
					SELF:_projects:Enqueue(xProject)
				ENDIF
				IF (! SELF:IsWalkerRunning .AND. ! xProject:ProjectNode:IsVsBuilding)
					//
					SELF:Walk()
				ENDIF
			END LOCK
			WriteOutputMessage("<<-- AddProject()")
        STATIC INSTANCE bOld := FALSE AS LOGIC
		INTERNAL METHOD FileWalk(file AS XFile) AS VOID
            IF ! XSolution.Open
                RETURN
            ENDIF
			VAR lastWriteTime := System.IO.File.GetLastWriteTime(file:SourcePath)
			IF lastWriteTime > file:LastWritten
				//
				BEGIN USING VAR walker := SourceWalker{file}
					TRY
						IF bOld
						    VAR lines := System.IO.File.ReadAllLines(file:SourcePath)
						    VAR xTree := walker:Parse(lines, FALSE)
						    walker:BuildModel(xTree)
//                        ELSE
//                            VAR cSource := System.IO.File.ReadAllText(file:SourcePath)
//                            VAR options := file:Project:ParseOptions
//            			    XSharp.Parser.VsParser.ParseForEntities(cSource, file:SourcePath, options, SELF, OUT VAR _, OUT VAR context)
                        ENDIF
						file:LastWritten := lastWriteTime
						IF file:Project != NULL
							//
							IF file:Project:FileWalkComplete != NULL
								//
								file:Project:FileWalkComplete?:Invoke(file)
							ENDIF
						ENDIF
						RETURN

					CATCH e AS Exception
						XSolution.WriteException(e)
					FINALLY
						IF walker != NULL
							//
							walker:Dispose()
						ENDIF
					END TRY
				END USING
			ENDIF

		STATIC METHOD GetWalker() AS ModelWalker
			//
			IF (ModelWalker._walker == NULL)
				//
				ModelWalker._walker := ModelWalker{}
			ENDIF
			RETURN ModelWalker._walker

		STATIC METHOD Resume() AS VOID
			//
			ModelWalker.suspendLevel--

		INTERNAL METHOD StopThread() AS VOID
			TRY
				IF (SELF:_WalkerThread == NULL)
					RETURN
				ENDIF
				IF (SELF:_WalkerThread:IsAlive)
					SELF:_WalkerThread:Abort()
				ENDIF
			CATCH exception AS System.Exception
				WriteOutputMessage("Cannot stop Background walker Thread : ")
				XSolution.WriteException(exception)
			END TRY
			SELF:_WalkerThread := NULL

		STATIC METHOD Suspend() AS VOID
			//
			ModelWalker.suspendLevel++
            IF (ModelWalker._walker != null .and. ModelWalker._walker:_projects:Count > 0)
                LOCAL project := NULL as XProject
                IF ModelWalker._walker:_projects:TryPeek(REF project)
                    project:ProjectNode:SetStatusBarText("")
                ENDIF
            ENDIF

		METHOD Walk() AS VOID
			LOCAL start AS System.Threading.ThreadStart
			IF (ModelWalker.suspendLevel <= 0 .and. XSolution:Open)
				TRY
					SELF:StopThread()
					start := System.Threading.ThreadStart{ SELF, @Walker() }
					SELF:_WalkerThread := System.Threading.Thread{start}
					SELF:_WalkerThread:IsBackground := TRUE
					SELF:_WalkerThread:Priority := System.Threading.ThreadPriority.Highest
					SELF:_WalkerThread:Name := "ModelWalker"
					SELF:_WalkerThread:Start()
				CATCH exception AS System.Exception
					WriteOutputMessage("Cannot start Background walker Thread : ")
					XSolution.WriteException(exception)

				END TRY
			ENDIF

		INTERNAL iProcessed AS LONG
		INTERNAL aFiles AS XFile[]
		PRIVATE METHOD Walker() AS VOID
			LOCAL project AS XProject
			LOCAL parallelOptions AS System.Threading.Tasks.ParallelOptions

			project := NULL
			IF ((SELF:_projects:Count != 0) .AND. ! System.Linq.Enumerable.First<XProject>(SELF:_projects):ProjectNode:IsVsBuilding)
				DO WHILE (TRUE)
					IF (ModelWalker.suspendLevel > 0)
						IF (project != NULL)
							SELF:_projects:Enqueue(project)
						ENDIF
						EXIT
					ENDIF
					BEGIN LOCK SELF
						IF ((SELF:_projects:Count == 0) .OR. ! SELF:_projects:TryDequeue( OUT project))
							EXIT
						ENDIF
						project:ProjectNode:SetStatusBarText(String.Format("Start scanning project {0}", project:Name))
                    END LOCK
					WriteOutputMessage("-->> Walker("+project.Name+")")
					aFiles := project:SourceFiles:ToArray()
					iProcessed := 0
					parallelOptions := ParallelOptions{}
					IF (System.Environment.ProcessorCount > 1)
						parallelOptions:MaxDegreeOfParallelism := ((System.Environment.ProcessorCount * 3) / 4)
					ENDIF
					project:ProjectNode:SetStatusBarAnimation(TRUE, 0)
                    TRY
					    Parallel.ForEach(aFiles, walkOneFile)
                    CATCH e as Exception

                        WriteOutPutMessage("Parallel.Foreach failed")
                        XSolution.WriteException(e)
                    END TRY
					BEGIN LOCK SELF
						_projectsForTypeResolution:Enqueue(project)
					END LOCK
					project:ProjectNode:SetStatusBarText("")
					project:ProjectNode:SetStatusBarAnimation(FALSE, 0)
					WriteOutputMessage("<<-- Walker("+project.Name+")")
                    project:FileWalkCompleted := TRUE
				ENDDO


			ENDIF
			IF ((SELF:_projectsForTypeResolution:Count != 0) .AND. ! System.Linq.Enumerable.First<XProject>(SELF:_projectsForTypeResolution):ProjectNode:IsVsBuilding)
				DO WHILE (TRUE)
					IF (ModelWalker.suspendLevel > 0)
						IF (project != NULL)
							SELF:_projectsForTypeResolution:Enqueue(project)
						ENDIF
						EXIT
					ENDIF

					BEGIN LOCK SELF
						IF ((SELF:_projectsForTypeResolution:Count == 0) .OR. ! SELF:_projectsForTypeResolution:TryDequeue( OUT project))
							EXIT
						ENDIF
					END LOCK
					WriteOutputMessage("-->> Walker() Resolve types "+project:Name)
					project:ResolveReferences()
					WriteOutputMessage("<<-- Walker() Resolve types "+project:Name)
				ENDDO

			ENDIF

		PRIVATE METHOD walkOneFile(file AS XFile) AS VOID
			VAR project := file:Project
			IF (project:Loaded .and. XSolution:Open)
				iProcessed++
				DO WHILE (project:ProjectNode:IsVsBuilding)
					System.Threading.Thread.Sleep(1000)
				ENDDO
				project:ProjectNode:SetStatusBarText(String.Format("Walking {0} : Processing File {1} ({2} of {3})", project:Name, file:Name, iProcessed, aFiles:Length))
				SELF:FileWalk(file)
			    DO WHILE ModelWalker.IsSuspended .AND. System.Threading.Thread.CurrentThread:IsBackground
				    System.Threading.Thread.Sleep(100)
			    ENDDO
			ENDIF
			RETURN

		// Properties
		PROPERTY HasWork AS LOGIC
			GET
				RETURN (SELF:_projects:Count > 0)
			END GET
		END PROPERTY

		STATIC PROPERTY IsSuspended AS LOGIC
			GET
				RETURN ModelWalker.suspendLevel > 0
			END GET
		END PROPERTY

		PROPERTY IsWalkerRunning AS LOGIC
			GET
				TRY
					IF SELF:_WalkerThread != NULL
						RETURN SELF:_WalkerThread:IsAlive
					ENDIF
				CATCH exception AS System.Exception
					//
					WriteOutputMessage("Cannot check Background walker Thread : ")
					XSolution.WriteException(exception)
				END TRY
				RETURN FALSE
			END GET
		END PROPERTY

		STATIC METHOD WriteOutputMessage(message AS STRING) AS VOID
			XSolution.WriteOutputMessage("XModel.Walker "+message)

			VIRTUAL METHOD ReportError(fileName AS STRING, span AS LinePositionSpan, errorCode AS STRING, message AS STRING, args AS OBJECT[]) AS VOID
                RETURN
			VIRTUAL METHOD ReportWarning(fileName AS STRING, span AS LinePositionSpan, errorCode AS STRING, message AS STRING, args AS OBJECT[]) AS VOID
                RETURN

	END CLASS

END NAMESPACE

