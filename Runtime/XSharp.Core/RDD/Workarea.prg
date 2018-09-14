﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
USING System.IO
USING System.Collections.Generic
USING XSharp.RDD
USING XSharp.RDD.Enums
USING XSharp.RDD.Support
BEGIN NAMESPACE XSharp.RDD

	/// <summary>Base class for DBF based RDDs. Holds common propertis such as the Workarea number, Alias, Fields list and various flags.</summary> 
	/// <seealso cref="T:XSharp.RDD.IRdd"/>
	CLASS Workarea IMPLEMENTS IRdd, IDisposable 
		// This class does NOT implement file based (DBF stuff). 
		// That is handled in the DBF class which inherits from RddBase
		#region Fields
		PROTECTED _Disposed     AS LOGIC
		/// <summary>Workarea Number (1 based) </summary>
		PUBLIC _Area			AS DWORD		
		/// <summary> Unique Alias </summary>
		PUBLIC _Alias			AS STRING	
		/// <summary>File name of the main file</summary>
		PUBLIC _FileName		AS STRING
		/// <summary>List of Fields</summary>
		PUBLIC _Fields		    AS RddFieldInfo[]	
		/// <summary>Is at BOF ?</summary>
		PUBLIC _Bof			    AS LOGIC	
		/// <summary>Is at bottom ?</summary>
		PUBLIC _Bottom		    AS LOGIC	
		/// <summary>Is at EOF ?</summary>
		PUBLIC _Eof			    AS LOGIC	
		/// <summary>Result of last SEEK operation</summary>
		PUBLIC _Found			AS LOGIC	
		/// <summary>Is at top?</summary>
		PUBLIC _Top			    AS LOGIC	
		/// <summary>Result of last macro evaluation</summary>
		PUBLIC _Result		    AS OBJECT                
		/// <summary>Current Scope</summary>
		PUBLIC _ScopeInfo		AS DbScopeInfo
		/// <summary>Current Filter</summary>
		PUBLIC _FilterInfo	    AS DbFilterInfo  
		/// <summary>Current Order condition</summary>
		PUBLIC _OrderCondInfo	AS DbOrderCondInfo
		/// <summary>Current Relation info</summary>
		PUBLIC _RelInfo		    AS DbRelInfo
		PUBLIC _Relations       AS List<DbRelInfo>
		/// <summary># of parents</summary>
		PUBLIC _Parents		    AS LONG		
		/// <summary>Maximum fieldname length (Advantage supports field names > 10 characters)</summary>
		PUBLIC _MaxFieldNameLength AS LONG	// 
		
		// Some flags that are stored here but managed in subclasses
		PUBLIC _TransRec		AS LOGIC
		/// <summary>Size of record</summary>
		PUBLIC _RecordLength	AS LONG   	
		/// <summary>Current Record</summary>
		PUBLIC _RecordBuffer	AS BYTE[]	
		/// <summary>Field delimiter (for DELIM RDD)</summary>
		PUBLIC _Delimiter		AS STRING	
		/// <summary>Field separator (for DELIM RDD)</summary>
		PUBLIC _Separator	    AS STRING	
		/// <summary> Is the file opened ReadOnly ?</summary>
		PUBLIC _ReadOnly		AS LOGIC	
		/// <summary> Is the file opened Shared ?</summary>
		PUBLIC _Shared			AS LOGIC	
		/// <summary>File handle of the current file</summary>
		PUBLIC _hFile			AS IntPtr
		/// <summary>Should the file be flushed (it is dirty) ?</summary>
		PUBLIC _Flush			AS LOGIC		
		
		// Memo and Order Implementation
		/// <summary>Current memo implementation.</summary>
		PUBLIC _Memo			AS IMemo
		/// <summary>Current index implementation.</summary>
		PUBLIC _Order			AS IOrder
		
		/// <summary>Result of the last Block evaluation.</summary>
		PUBLIC _EvalResult    AS OBJECT
		#endregion
		
		#region Static Properties that point to Runtime state ?
		// Ansi
		// AutoOrder
		// AutoShare
		// etc
		#endregion
		
		CONSTRUCTOR() 
			SELF:_FilterInfo := DbFilterInfo{}
			SELF:_ScopeInfo  := DbScopeInfo{}            
			SELF:_OrderCondInfo := DbOrderCondInfo{}
			SELF:_Relations  := List<DbRelInfo>{}
			SELF:_Parents	 := 0   
			SELF:_Memo		 := BaseMemo{SELF}
			SELF:_Order		 := BaseIndex{SELF}     
			SELF:_Result	 := NULL
			SELF:_FileName	 := String.Empty
			SELF:_Fields	 := NULL
			SELF:_Area		 := 0
			SELF:_Shared	 := FALSE
			SELF:_ReadOnly   := FALSE
			SELF:_MaxFieldNameLength := 10
			SELF:_RelInfo    := NULL
			SELF:_Alias		 := String.Empty
			SELF:_RecordBuffer := NULL
			SELF:_Disposed   := FALSE
			
		DESTRUCTOR()
			SELF:Dispose(FALSE)
			
		VIRTUAL METHOD Dispose(disposing AS LOGIC) AS VOID
			IF !_Disposed
				_Disposed := TRUE
			ENDIF
			
		VIRTUAL METHOD Dispose() AS VOID
			SELF:Dispose(TRUE)
			GC.SuppressFinalize(SELF)
			RETURN
			
			/// <inheritdoc />			
		VIRTUAL METHOD DbEval(info AS DbEvalInfo) AS LOGIC
			//Todo Implement DbEval
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD GoTop( ) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD GoBottom( ) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD GoTo(nRec AS INT) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD GoToId(oRec AS OBJECT) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD Skip(nToSkip AS INT) AS LOGIC
			LOCAL lToSkip AS LONG
			IF nToSkip == 0
				RETURN SELF:SkipRaw(0)
			ENDIF
			SELF:_Top := SELF:_Bottom := FALSE
			IF nToSkip > 0
				lToSkip := 1 	// Forward
			ELSE
				lToSkip := -1	// Backward
				nToSkip := - nToSkip
			ENDIF
			DO WHILE --nToSkip >= 0
				IF !SELF:SkipRaw(lToSkip)
					RETURN FALSE
				ENDIF
				IF !SELF:SkipFilter(lToSkip)
					RETURN FALSE
				ENDIF              
				IF SELF:_BOF .OR. SELF:_EOF
					EXIT
				ENDIF
			ENDDO
			IF lToSkip < 0
				SELF:_EOF := FALSE		
			ELSE
				SELF:_Bof := FALSE
			ENDIF
			RETURN TRUE	
			
			/// <inheritdoc />
			// Todo
		VIRTUAL METHOD SkipFilter(nToSkip AS INT) AS LOGIC
			//LOCAL Bottom /*, Deleted */ AS LOGIC
			// When no active filter, record is Ok
			//            IF SELF:_FilterInfo == NULL_OBJECT .OR. ;
			//            !SELF:_FilterInfo:Active .OR. ;
			//            SELF:_FilterInfo:FilterBlock == NULL_OBJECT ;
			//            // .or. !SetDeleted()
			//                RETURN TRUE
			//            ENDIF
			//            nToSkip := IIF(nToSkip < 0 , -1, 1)
			//            Bottom := SELF:_Bottom    
			RETURN FALSE
			/*
			WHILE( ! pArea->fBof && ! pArea->fEof )
			{
			/* SET DELETED * /
			IF( hb_setGetDeleted() )
			{
			IF( SELF_DELETED( pArea, &fDeleted ) != HB_SUCCESS )
			RETURN HB_FAILURE;
			IF( fDeleted )
			{
			IF( SELF_SKIPRAW( pArea, lUpDown ) != HB_SUCCESS )
			RETURN HB_FAILURE;
			continue;
			}
			}
			
			/* SET FILTER TO * /
			IF( pArea->dbfi.itmCobExpr )
			{
			IF( SELF_EVALBLOCK( pArea, pArea->dbfi.itmCobExpr ) != HB_SUCCESS )
			RETURN HB_FAILURE;
			
			IF( HB_IS_LOGICAL( pArea->valResult ) &&
			! hb_itemGetL( pArea->valResult ) )
			{
			IF( SELF_SKIPRAW( pArea, lUpDown ) != HB_SUCCESS )
			RETURN HB_FAILURE;
			continue;
			}
			}
			
			BREAK;
			}
			
			/*
			* The only one situation when we should repos is backward skipping
			* if we are at BOTTOM position (it's SKIPFILTER called from GOBOTTOM)
			* then GOEOF() if not then GOTOP()
			* /
			IF( pArea->fBof && lUpDown < 0 )
			{
			IF( fBottom )
			{
			/* GOTO EOF (phantom) record -
			this IS the only one place WHERE GOTO IS used BY Harbour
			directly and RDD which does not operate ON numbers should
			serve this METHOD only AS SELF_GOEOF() synonym. IF it's a
			problem then we can REMOVE this IF and always use SELF_GOTOP()
			but it also means second table scan IF all records filtered
			are OUT OF filter so I DO not want TO DO that. I will prefer
			explicit ADD SELF_GOEOF() METHOD
			* /
			errCode = SELF_GOTO( pArea, 0 );
			}
			ELSE
			{
			errCode = SELF_GOTOP( pArea );
			pArea->fBof = HB_TRUE;
			}
			}
			ELSE
			{
			errCode = HB_SUCCESS;
			}
			
			RETURN errCode; 
			*/		
			
		/// <inheritdoc />
		VIRTUAL METHOD SkipRaw(nToSkip AS INT) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD SkipScope(nToSkip AS INT) AS LOGIC
			// Todo: Implement SkipScope
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD Append(lReleaseLock AS LOGIC) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD Delete( ) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD GetRec( ) AS BYTE[]
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD Pack( ) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD PutRec(aRec AS BYTE[]) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD Recall( ) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD Zap( ) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD Close( ) AS LOGIC
			SELF:ClearFilter()
			SELF:ClearRel()
			SELF:ClearScope()
			// close all parent relations
			IF SELF:_Parents > 0
				//
				LOCAL max AS DWORD
				max := 4096 // RuntimeState.Workareas.MaxWorkAreas <- what's wrong here ??
				FOR VAR i := 1 TO max
					VAR rdd := XSharp.RuntimeState.Workareas:GetRDD( (DWORD)i )
					VAR wk := rdd ASTYPE Workarea
					IF ( wk != NULL ) .AND. ( wk != SELF )
						wk:_Relations:RemoveAll( SELF:isChildPredicate )
					ENDIF
				NEXT
			ENDIF
			RETURN TRUE
			
			/// <inheritdoc />
		VIRTUAL METHOD Create(info AS DbOpenInfo) AS LOGIC
			// todo: basic implementation
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD Open(info AS DbOpenInfo) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD ClearFilter( ) AS LOGIC
			IF SELF:_FilterInfo != NULL
				SELF:_FilterInfo:Clear()
			ELSE
				SELF:_FilterInfo := DbFilterInfo{}
			ENDIF
			RETURN TRUE
			
			/// <inheritdoc />
		VIRTUAL METHOD ClearScope( ) AS LOGIC
			IF SELF:_ScopeInfo != NULL        
				SELF:_ScopeInfo:Clear()
			ELSE 
				SELF:_ScopeInfo := DbScopeInfo{}
			ENDIF 
			RETURN TRUE
			
			/// <inheritdoc />
		VIRTUAL METHOD Continue( ) AS LOGIC
			// Todo: Implement Continue
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD GetScope( ) AS DbScopeInfo
			IF SELF:_ScopeInfo != NULL_OBJECT
				RETURN SELF:_ScopeInfo:Clone()
			ENDIF
			RETURN DbScopeInfo{}
			
			/// <inheritdoc />
		VIRTUAL METHOD ScopeInfo(nOrdinal AS INT) AS OBJECT
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD SetFilter(info AS DbFilterInfo) AS LOGIC
			SELF:ClearFilter()
			IF info != NULL_OBJECT
				SELF:_FilterInfo := info:Clone()
				SELF:_FilterInfo:Active := TRUE
			ENDIF
			RETURN TRUE
			
		VIRTUAL METHOD SetFieldExtent( fieldCount AS LONG ) AS LOGIC
			// Initialize the Fields array
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD SetScope(info AS DbScopeInfo) AS LOGIC
			SELF:ClearScope()
			IF (info != NULL_OBJECT)
				SELF:_ScopeInfo := info:Clone()
			ENDIF
			RETURN TRUE
			
		VIRTUAL METHOD SetFieldExtent(uiCount AS DWORD) AS LOGIC
			//Todo Copy implementation from DBF or ADS
			RETURN FALSE
			
			/// <inheritdoc />
		VIRTUAL METHOD AddField(info AS RddFieldInfo) AS LOGIC
			// ToDo
			// Copy implementation from ADS or DBF
			// including _CheckFIeldName
			
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD CreateFields(aFields AS RddFieldInfo[]) AS LOGIC
			// ToDo
			// Copy implementation from ADS or DBF
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD FieldIndex(fieldName AS STRING) AS INT
			LOCAL nMax AS INT
			nMax := SELF:FieldCount
			FOR VAR nFldPos := 0 TO nMax -1
				IF SELF:_Fields[nFldPos] != NULL .AND. String.Compare(SELF:_Fields[nFldPos]:Name, fieldName, StringComparison.OrdinalIgnoreCase) == 0
					// Note that we must return 1 based fldPos
					RETURN nFldPos+1
				ENDIF
			NEXT 
			RETURN 0
			
			/// <inheritdoc />
		PROTECTED METHOD _FieldIndexValidate(nFldPos AS LONG) AS LOGIC
			LOCAL nMax AS INT
			// Note that nFldPos is 1 based
			nMax := (INT) SELF:_Fields?:Length  
			IF nFldPos <= 0 .OR. nFldPos > nMax 
				THROW ArgumentException{"Invalid Field Index, must be between 1 and "+SELF:FieldCount:ToString(), NAMEOF(nFldPos)}
			ENDIF
			RETURN TRUE	
			
			/// <inheritdoc />
		VIRTUAL METHOD FieldInfo(nFldPos AS LONG, nOrdinal AS LONG, oNewValue AS OBJECT) AS OBJECT
			// Note that nFldPos is 1 based
			// Todo implement basic NAME, LEN, TYPE, DEC info
			IF SELF:_FieldIndexValidate(nFldPos)
				IF __ARRAYBASE__ == 0
					nFldPos -= 1
				ENDIF
			ENDIF
			THROW NotImplementedException{__ENTITY__}
			
		VIRTUAL METHOD GetField(nFldPos AS INT) AS RDDFieldInfo
			IF SELF:_FieldIndexValidate(nFldPos)
				IF __ARRAYBASE__ == 0
					nFldPos -= 1
				ENDIF
				RETURN SELF:_Fields[nFldPos]
			ENDIF          
			RETURN NULL
			
			
			/// <inheritdoc />
		VIRTUAL METHOD FieldName(nFldPos AS INT) AS STRING
			// Note that nFldPos is 1 based
			IF SELF:_FieldIndexValidate(nFldPos)
				IF __ARRAYBASE__ == 0
					nFldPos -= 1
				ENDIF
				RETURN SELF:_Fields[nFldPos]:Name
			ENDIF          
			RETURN String.Empty
			
			/// <inheritdoc />
		VIRTUAL METHOD GetValue(nFldPos AS INT) AS OBJECT
			// Note that nFldPos is 1 based
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD GetValueFile(nFldPos AS INT, fileName AS STRING) AS LOGIC
			// Note that nFldPos is 1 based
			RETURN _Memo:GetValueFile(nFldPos, fileName )
			
			/// <inheritdoc />
		VIRTUAL METHOD GetValueLength(nFldPos AS INT) AS INT
			// Note that nFldPos is 1 based
			RETURN _Memo:GetValueLength(nFldPos )
			
			/// <inheritdoc />
		VIRTUAL METHOD Flush( ) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD GoCold( ) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD GoHot( ) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD PutValue(nFldPos AS INT, oValue AS OBJECT) AS LOGIC
			// Note that nFldPos is 1 based
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD PutValueFile(nFldPos AS INT, fileName AS STRING) AS LOGIC
			// Note that nFldPos is 1 based
			RETURN _Memo:PutValueFile(nFldPos, fileName )
			
			/// <inheritdoc />
		VIRTUAL METHOD AppendLock(uiMode AS DbLockMode) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD HeaderLock(uiMode AS DbLockMode) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD Lock(uiMode REF DbLockInfo) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD UnLock(oRecId AS OBJECT) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD CloseMemFile( ) AS LOGIC
			RETURN SELF:_Memo:CloseMemFile()
			
			/// <inheritdoc />
		VIRTUAL METHOD CreateMemFile(info AS DbOpenInfo) AS LOGIC
			RETURN SELF:_Memo:CreateMemFile(info)
			
			/// <inheritdoc />
		VIRTUAL METHOD OpenMemFile( info AS DbOpenInfo) AS LOGIC
			RETURN SELF:_Memo:OpenMemFile(info )
			
			#region Orders Not implemented
			
			/// <inheritdoc />
			VIRTUAL METHOD OrderCondition(info AS DbOrderCondInfo) AS LOGIC
				RETURN SELF:_Order:OrderCondition(info)
				
				/// <inheritdoc />
			VIRTUAL METHOD OrderCreate(info AS DbOrderCreateInfo) AS LOGIC
				RETURN SELF:_Order:OrderCreate(info)
				
				/// <inheritdoc />
			VIRTUAL METHOD OrderDestroy(info AS DbOrderInfo) AS LOGIC
				RETURN SELF:_Order:OrderDestroy(info)
				
				/// <inheritdoc />
			VIRTUAL METHOD OrderInfo(nOrdinal AS DWORD, info AS DbOrderInfo) AS OBJECT
				/* CA-Cl*pper does not generate RT error when default ORDERINFO() method
				* is called
				*/
				RETURN SELF:_Order:OrderInfo(nOrdinal, info)
				
				/// <inheritdoc />
			VIRTUAL METHOD OrderListAdd(info AS DbOrderInfo) AS LOGIC
				RETURN SELF:_Order:OrderListAdd(info)
				
				/// <inheritdoc />
			VIRTUAL METHOD OrderListDelete(info AS DbOrderInfo) AS LOGIC
				RETURN SELF:_Order:OrderListDelete(info)
				
				/// <inheritdoc />
			VIRTUAL METHOD OrderListFocus(info AS DbOrderInfo) AS LOGIC
				RETURN SELF:_Order:OrderListFocus(info)
				
				/// <inheritdoc />
			VIRTUAL METHOD OrderListRebuild( ) AS LOGIC
				RETURN SELF:_Order:OrderListRebuild()
				
				/// <inheritdoc />
			VIRTUAL METHOD Seek(info AS DbSeekInfo) AS LOGIC
				RETURN SELF:_Order:Seek(info)
				#endregion
				
				
			#region Relations
			
			/// <inheritdoc />
			VIRTUAL METHOD ChildEnd(info AS DbRelInfo) AS LOGIC
				SELF:_Parents --
				RETURN TRUE
				
				/// <inheritdoc />
			VIRTUAL METHOD ChildStart(info AS DbRelInfo) AS LOGIC
				SELF:_Parents ++
				RETURN TRUE
				
				/// <inheritdoc />
			VIRTUAL METHOD ChildSync(info AS DbRelInfo) AS LOGIC
				// Todo: Implement ChildSync
				THROW NotImplementedException{__ENTITY__}

			PRIVATE METHOD isChildPredicate( info AS DbRelInfo ) AS LOGIC
				// Is Child ?
				RETURN ( info:Child == SELF )
								
				/// <inheritdoc />
			VIRTUAL METHOD ClearRel( ) AS LOGIC
				LOCAL isOk AS LOGIC
				//
				isOk := TRUE
				//
				FOREACH info AS DbRelInfo IN SELF:_Relations
					isOk := isOk .AND. info:Child:ChildEnd( info )
				NEXT
				SELF:_Relations:Clear()
				RETURN isOk
				
				/// <inheritdoc />
			VIRTUAL METHOD ForceRel( ) AS LOGIC
				THROW NotImplementedException{__ENTITY__}
				
				/// <inheritdoc />
			VIRTUAL METHOD RelArea(nRelNum AS DWORD) AS DWORD
				LOCAL areaNum := 0 AS DWORD
				IF ( nRelNum < SELF:_Relations:Count )
					areaNum := SELF:_Relations[ (INT)nRelNum ]:Child:Area
				ENDIF
				RETURN areaNum
				
				/// <inheritdoc />
			VIRTUAL METHOD RelEval(info AS DbRelInfo) AS LOGIC
				LOCAL currentWk AS DWORD
				//
				currentWk := XSharp.RuntimeState.Workareas:CurrentWorkAreaNO
				TRY
					XSharp.RuntimeState.CurrentWorkArea := info:Parent:Area
					SELF:_EvalResult := info:Block:EvalBlock()
				FINALLY
					XSharp.RuntimeState.Workareas:CurrentWorkAreaNO := currentWk
				END TRY
				RETURN ( SELF:_EvalResult != NULL )
				
				/// <inheritdoc />
			VIRTUAL METHOD RelText(nRelNum AS DWORD) AS STRING
				LOCAL textRelation := "" AS STRING
				IF ( nRelNum < SELF:_Relations:Count )
					textRelation := SELF:_Relations[ (INT)nRelNum ]:Key
				ENDIF
				RETURN textRelation
				
				/// <inheritdoc />
			VIRTUAL METHOD SetRel(info AS DbRelInfo) AS LOGIC
				IF !SELF:_Relations:Contains( info )
					SELF:_Relations:Add( info )
				ENDIF
				RETURN info:Child:ChildStart( info )

				/// <inheritdoc />
			VIRTUAL METHOD SyncChildren( ) AS LOGIC
				LOCAL isOk AS LOGIC
				//
				isOk := TRUE
				//
				FOREACH info AS DbRelInfo IN SELF:_Relations
					isOk := info:Child:ChildSync( info )
					IF !isOk
						EXIT
					ENDIF
				NEXT
				RETURN isOk
				
				#endregion
				
			#region Trans not implemented
			
			/// <inheritdoc />
			VIRTUAL METHOD Trans(info AS DbTransInfo) AS LOGIC
				// Todo: Implement Trans
				THROW NotImplementedException{__ENTITY__}
				
				/// <inheritdoc />
			VIRTUAL METHOD TransRec(info AS DbTransInfo) AS LOGIC
				// Todo: Implement Trans
				THROW NotImplementedException{__ENTITY__}
				
				#endregion
				
			/// <inheritdoc />
		VIRTUAL METHOD BlobInfo(uiPos AS DWORD, uiOrdinal AS DWORD) AS OBJECT
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL METHOD Compile(sBlock AS STRING) AS ICodeBlock
			LOCAL oBlock := NULL AS ICodeBlock
			TRY
				LOCAL oC AS IMacroCompiler
				oC := XSharp.RuntimeState.MacroCompiler
				LOCAL oType := typeof(Workarea) AS System.Type
				IF oC != NULL
					LOCAL isBlock AS LOGIC
					oBlock := oC:Compile(sBlock, TRUE, oType:Module, OUT isBlock)
				ENDIF
			CATCH e AS Exception
				XSharp.RuntimeState.LastRddError := e
			END TRY
			RETURN oBlock
			
			/// <inheritdoc />
		VIRTUAL METHOD EvalBlock(oBlock AS ICodeBlock) AS OBJECT
			// Todo: Save and restore workarea 
			RETURN oBlock:EvalBlock()
			
			/// <inheritdoc />
		VIRTUAL METHOD Info(nOrdinal AS INT, oNewValue AS OBJECT) AS OBJECT
			LOCAL oResult AS OBJECT
			// todo check basic implementation
			SWITCH nOrdinal
			CASE DBI_ISDBF
				CASE DBI_CANPUTREC
				CASE DBI_ISFLOCK
				CASE DBI_TRANSREC
				CASE DBI_RM_SUPPORTED
					oResult := FALSE      
				CASE DBI_SHARED
					oResult := SELF:_Shared
				CASE DBI_ISREADONLY
					oResult := SELF:_ReadOnly
				CASE DBI_GETDELIMITER
					oResult := SELF:_Delimiter
				CASE DBI_SEPARATOR
					oResult := SELF:_Separator
				CASE DBI_SETDELIMITER            
					oResult := SELF:_Separator		
					IF oNewValue != NULL .AND. oNewValue:GetType() == TYPEOF(STRING)
						SELF:_Separator	:= (STRING) oNewValue
					ENDIF
				CASE DBI_DB_VERSION
				CASE DBI_RDD_VERSION
					oResult := ""
				CASE DBI_GETHEADERSIZE
				CASE DBI_LOCKCOUNT
					oResult := 0     
				CASE DBI_GETRECSIZE
					oResult := SELF:_RecordLength
				CASE DBI_LASTUPDATE
					oResult := DateTime.MinValue 
				CASE DBI_GETLOCKARRAY
					oResult := <DWORD>{}
				CASE DBI_BOF           
					oResult := SELF:_BOF
				CASE DBI_EOF           
					oResult := SELF:_EOF   
				CASE DBI_DBFILTER      
					oResult := SELF:_FilterInfo?:FilterText
				CASE DBI_FOUND
					oResult := SELF:_Found
				CASE DBI_FCOUNT
					oResult := (INT) _Fields?:Length
				CASE DBI_ALIAS
					oResult := _Alias
				CASE DBI_FULLPATH
					oResult := SELF:_FileName
					// CASE DBI_CHILDCOUNT:
					// CASE DBI_TABLEEXT
					// CASE DBI_SCOPEDRELATION
					// CASE DBI_POSITIONED
					// CASE DBI_CODEPAGE
				OTHERWISE
					oResult := NULL
				END SWITCH
			RETURN oResult
			
			
			/// <inheritdoc />
		VIRTUAL METHOD RecInfo(oRecID AS OBJECT, nOrdinal AS LONG, oNewValue AS OBJECT) AS OBJECT  
			LOCAL oResult AS OBJECT
			//Todo: Basic implementation of Recno deleted etc.
			SWITCH nOrdinal
			
				// etc
				OTHERWISE
					oResult := NULL
			END SWITCH
			RETURN oResult
			
			/// <inheritdoc />
		VIRTUAL METHOD Sort(info AS DbSortInfo) AS LOGIC
			THROW NotImplementedException{__ENTITY__}
			
			/// <inheritdoc />
		VIRTUAL PROPERTY Alias AS STRING GET _Alias SET _Alias := VALUE
		
		/// <inheritdoc />
		VIRTUAL PROPERTY Area AS DWORD GET _Area SET _Area := VALUE 
		
		/// <inheritdoc />
		VIRTUAL PROPERTY BoF AS LOGIC GET _Bof
		
		/// <inheritdoc />
		VIRTUAL PROPERTY Deleted AS LOGIC GET FALSE
		
		/// <inheritdoc />
		VIRTUAL PROPERTY Driver AS STRING GET "Workarea"
		
		/// <inheritdoc />
		VIRTUAL PROPERTY EoF AS LOGIC GET _Eof
		
		/// <inheritdoc />
		VIRTUAL PROPERTY Exclusive AS LOGIC GET FALSE
		
		/// <inheritdoc />
		VIRTUAL PROPERTY FieldCount AS LONG GET (LONG) _Fields?:Length
		
		/// <inheritdoc />
		VIRTUAL PROPERTY FilterText AS STRING GET _FilterInfo?:FilterText
		
		/// <inheritdoc />
		VIRTUAL PROPERTY Found AS LOGIC GET _Order:Found SET _Order:Found := VALUE
		
		
		/// <inheritdoc />
		VIRTUAL PROPERTY RecCount AS INT GET 0
		
		/// <inheritdoc />
		VIRTUAL PROPERTY RecId AS OBJECT GET NULL
		/// <inheritdoc />
		VIRTUAL PROPERTY RecNo AS LONG GET   0	
		
		/// <inheritdoc />
		VIRTUAL PROPERTY Shared AS LOGIC GET FALSE
		
		/// <inheritdoc />
		VIRTUAL PROPERTY SysName AS STRING GET TYPEOF(Workarea):ToString()
		
	END CLASS

END NAMESPACE

