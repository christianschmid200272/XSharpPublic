//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//

USING System.IO
/// <summary>
/// Fill a series of Array with directory information.
/// </summary>
/// <param name="cPath"></param>
/// <param name="aFNAME"></param>
/// <param name="aFSIZE"></param>
/// <param name="aFDATE"></param>
/// <param name="aFTIME"></param>
/// <param name="aFATTR"></param>
/// <returns>
/// </returns>
FUNCTION ADir(cPath ,aFNAME ,aFSIZE ,aFDATE ,aFTIME ,aFATTR ) AS DWORD CLIPPER
	IF ! cPath:IsString
		THROW Error.ArgumentError(__FUNCTION__, NAMEOF(cPath), 2,<OBJECT>{cPath})
	ENDIF
	LOCAL aFiles	AS ARRAY
	LOCAL lHasArg   := FALSE AS LOGIC
	LOCAL aNames	:= NULL_ARRAY AS ARRAY
	LOCAL aSizes	:= NULL_ARRAY AS ARRAY
	LOCAL aDates	:= NULL_ARRAY AS ARRAY
	LOCAL aTimes    := NULL_ARRAY AS ARRAY
	LOCAL aAttribs  := NULL_ARRAY AS ARRAY
	aFiles := Directory(cPath,FA_NORMAL)
	IF aFName:IsArray
		aNames  := aFName
		lHasArg := TRUE
	ENDIF
	IF aFSize:IsArray
		aSizes  := aFSize
		lHasArg := TRUE
	ENDIF
	IF aFDate:IsArray
		aDates  := aFDate
		lHasArg := TRUE
	ENDIF
	IF aFTIME:IsArray
		aTimes  := aFTIME
		lHasArg := TRUE
	ENDIF
	IF aFAttr:IsArray
		aAttribs  := aFAttr
		lHasArg := TRUE
	ENDIF
	IF ALen(aFiles) > 0 .AND. lHasArg
		LOCAL x AS DWORD
		FOR x := 1 TO ALen(aFiles)
			VAR aFile := aFiles[x]
			IF aNames != NULL_ARRAY .AND. x <= ALen(aNames)
				aNames[x] := aFile[ F_NAME]
			ENDIF
			IF aSizes != NULL_ARRAY .AND. x <= ALen(aSizes)
				aSizes[x] := aFile[ F_SIZE]
			ENDIF
			IF aDates != NULL_ARRAY .AND. x <= ALen(aDates)
				aDates[x] := aFile[ F_DATE]
			ENDIF
			IF aTimes != NULL_ARRAY .AND. x <= ALen(aTimes)
				aTimes[x] := aFile[ F_TIME]
			ENDIF
			IF aAttribs != NULL_ARRAY .AND. x <= ALen(aAttribs)
				aAttribs[x] := aFile[ F_ATTR]
			ENDIF
		NEXT
	ENDIF
	RETURN ALen(aFiles)
	
	
	
	
	
/// <summary>
/// Create an Array of directory and file information.
/// </summary>
/// <param name="cFileSpec">The file specification for the search.  Besides a file name, this specification can include an optional drive, directory, and extension.  The file name and extension can include the standard wildcard characters (* and ?).  If you do not specify a drive and directory, the Windows defaults are used.</param>
/// <param name="xAttr">Specifies inclusion of files with special attributes in the returned information.  uAttributes can be a string or a numeric.</param>
/// <returns>An array of subarrays, with each subarray containing information about each file matching cFileSpec.  </returns>
FUNCTION Directory(cFileSpec AS STRING, xAttr := NIL AS USUAL) AS ARRAY
	LOCAL nAttr		AS DWORD
	LOCAL aReturn	AS ARRAY
	LOCAL cPath		AS STRING
	LOCAL cFileMask AS STRING
	IF xAttr:IsNil
		nAttr := 0
	ELSEIF xAttr:IsNumeric
		nAttr := (DWORD) xAttr
	ELSEIF xAttr:IsString
		nAttr := String2FAttr((STRING) xAttr)
	ELSE
		THROW Error.ArgumentError(__FUNCTION__, NAMEOF(xAttr), 2,<OBJECT>{xAttr})
	ENDIF
	aReturn := {}
	IF (nAttr & FA_VOLUME ) != 0
		TRY
			AAdd(aReturn, {DriveInfo{cFileSpec}:VolumeLabel, 0, NULL_DATE, "00:00:00", "V"})
		END TRY
	ENDIF
	IF System.IO.Directory.Exists(cFileSpec)
		cFileSpec += "\*.*"
	ELSEIF cFileSpec:EndsWith("\")
		cFileSpec += "*.*"
	ELSEIF cFileSpec:Length == 2 && cFileSpec[1] == ':' .AND. Char.IsLetter( cFileSpec, 0 )   // only a drive letter specified
		VAR  curdir := Environment.CurrentDirectory 
		IF Char.ToUpper( cFileSpec[0] ) == Char.ToUpper( curdir[0] )  // if same drive, use current directory
			cFileSpec := curdir + "\*.*"
		ELSE
			cFileSpec += "\*.*"
		ENDIF   
	ENDIF
	TRY
		cPath := Path.GetDirectoryName(cFileSpec)
	CATCH
		cPath := ""
	END TRY   
	
	IF String.IsNullOrEmpty( cPath )
		cPath := System.IO.Directory.GetCurrentDirectory()
	ENDIF
	
	cFileMask := Path.GetFileName( cFileSpec )
	
	IF _AND( nAttr,FA_DIRECTORY ) == FA_DIRECTORY
		_DirectoryAddDirectoryInfo( aReturn, cFileSpec, nAttr , NULL)
	ENDIF
	
	// File Info
	LOCAL files AS STRING[]
	TRY
		files := System.IO.Directory.GetFiles( cPath, cFileMask )
		IF files != NULL
			FOREACH cFile AS STRING IN files
				VAR oFile := System.IO.FileInfo{cFile}
				_DirectoryAddFileInfo(aReturn, oFile, nAttr)			
			NEXT
		ENDIF
	CATCH
		NOP
	END TRY
	
	// Directory info
	IF _AND( nAttr, FA_DIRECTORY) == FA_DIRECTORY .AND. ( cFileSpec:Contains( "*" ) || cFileSpec:Contains( "?" ) )
	
		IF Path.GetDirectoryName( cFileSpec ) != Path.GetPathRoot( cFileSpec ) .AND. ( Path.GetFileName( cFileSpec ) == "*.*" || Path.GetFileName( cFileSpec ) == "*" )
			_DirectoryAddDirectoryInfo( aReturn, Path.GetDirectoryName( cFileSpec ), nAttr, "." )
			_DirectoryAddDirectoryInfo( aReturn, Path.GetDirectoryName( cFileSpec ), nAttr, ".." )
		ENDIF         
		
		TRY 
			files := System.IO.Directory.GetDirectories( Path.GetDirectoryName( cFileSpec ), Path.GetFileName( cFileSpec ) )
			FOR VAR i := 1 UPTO files:Length
				_DirectoryAddDirectoryInfo( aReturn, files[i], nAttr, NULL )
			NEXT
		CATCH
			NOP
		END TRY
	ENDIF
	
	IF ALen(aReturn) > 1
		aReturn := ASort( aReturn, 1, aReturn:Length, {|x,y| x[1] < y[1] } )	
	ENDIF
	RETURN aReturn

INTERNAL FUNCTION _DirectoryAddFileInfo(aReturn AS ARRAY, oFile AS System.IO.FileInfo, nAttr AS DWORD) AS VOID
    
	LOCAL cAttribute := "" AS STRING
			
	LOCAL lOk := TRUE AS LOGIC
	IF oFile:Attributes:HasFlag(System.IO.FileAttributes.ReadOnly) 
		cAttribute += "R"
	ENDIF
	IF oFile:Attributes:HasFlag(System.IO.FileAttributes.Hidden) 
		lOk := lOk .AND. _AND(nAttr,FC_HIDDEN) == FC_HIDDEN
		cAttribute += "H"
	ENDIF
	IF oFile:Attributes:HasFlag(System.IO.FileAttributes.System) 
		lOk := lOk .AND. _AND(nAttr,FC_SYSTEM) == FC_SYSTEM
		cAttribute += "S"
	ENDIF
	IF oFile:Attributes:HasFlag(System.IO.FileAttributes.Archive) 
		cAttribute += "A"
	ENDIF
	IF lOk
        VAR aFile := ArrayNew(F_LEN)
        aFile[F_NAME] := oFile:Name
        aFile[F_SIZE] := oFile:Length
        IF oFile:Length < 0x7FFFFFFFL
            aFile[F_SIZE] := (Int32) oFile:Length
        ENDIF
        aFile[F_DATE] := (DATE)  oFile:LastWriteTime
        aFile[F_TIME] := ConTime(oFile:LastWriteTime)
        aFile[F_ATTR] := cAttribute
        aFile[F_EA_SIZE] := oFile:Attributes
        aFile[F_CREATION_DATE] := (DATE)  oFile:CreationTime
        aFile[F_CREATION_TIME] := ConTime(oFile:CreationTime)
        aFile[F_ACCESS_DATE] := (DATE)  oFile:LastAccessTime
        aFile[F_ACCESS_TIME] := ConTime(oFile:LastAccessTime)
        aadd(aReturn, aFile)
	ENDIF
	RETURN
	
INTERNAL FUNCTION _DirectoryAddDirectoryInfo( aReturn AS ARRAY, cDirectory AS STRING, nAttr AS DWORD, cName AS STRING ) AS VOID
	TRY
		LOCAL oDir := System.IO.DirectoryInfo{ cDirectory } AS DirectoryInfo
		IF oDir:Exists
			VAR cAttribute := ""
			VAR lAdd       := TRUE
		
			IF oDir:Attributes:HasFlag( System.IO.FileAttributes.ReadOnly ) 
				cAttribute += "R"
			ENDIF
		
			IF oDir:Attributes:HasFlag( System.IO.FileAttributes.Hidden ) 
				cAttribute += "H"
				lAdd := lAdd .AND. _AND( nAttr,FC_HIDDEN ) == FC_HIDDEN
			ENDIF
		
			IF oDir:Attributes:HasFlag( System.IO.FileAttributes.System ) 
				cAttribute += "S"
				lAdd := lAdd .AND. _AND( nAttr,FC_SYSTEM ) == FC_SYSTEM
			ENDIF
		
			IF lAdd
				cAttribute += "D"
                VAR aFile := ArrayNew(F_LEN)
                aFile[F_NAME] := oDir:Name
                aFile[F_SIZE] := 0 
                aFile[F_DATE] := (DATE)  oDir:LastWriteTime
                aFile[F_TIME] := ConTime(oDir:LastWriteTime)
                aFile[F_ATTR] := cAttribute
                aFile[F_EA_SIZE] := oDir:Attributes
                aFile[F_CREATION_DATE] := (DATE)  oDir:CreationTime
                aFile[F_CREATION_TIME] := ConTime(oDir:CreationTime)
                aFile[F_ACCESS_DATE] := (DATE)  oDir:LastAccessTime
                aFile[F_ACCESS_TIME] := ConTime(oDir:LastAccessTime)
                aadd(aReturn, aFile)
			ENDIF
		ENDIF
	CATCH 
		NOP
	END TRY   

	RETURN  





