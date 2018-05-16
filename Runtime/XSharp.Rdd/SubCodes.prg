﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//

BEGIN NAMESPACE XSharp.RDD
ENUM ERDD
	MEMBER MIN                  := 1100
	MEMBER OPEN_FILE			
	MEMBER OPEN_MEMO			
	MEMBER OPEN_ORDER 			
	MEMBER CREATE_FILE			
	MEMBER CREATE_MEMO			
	MEMBER CREATE_ORDER			:= 1106
	MEMBER READ					:= 1110
	MEMBER WRITE				
	MEMBER CORRUPT				
	MEMBER CORRUPT_HEADER 		

	MEMBER RDDVERSION 			:= 1115

	MEMBER DATATYPE				:= 1120
	MEMBER DATAWIDTH			
	MEMBER UNLOCKED				
	MEMBER SHARED 				
	MEMBER APPENDLOCK 			
	MEMBER READONLY				
	MEMBER NULLKEY				
	MEMBER NTXLIMIT				
	MEMBER TAGLIMIT				

	MEMBER INIT_LOCK		    := 1130
	MEMBER READ_LOCK			
	MEMBER WRITE_LOCK 			
	MEMBER READ_UNLOCK			
	MEMBER WRITE_UNLOCK			
	MEMBER READ_LOCK_TIMEOUT	
	MEMBER WRITE_LOCK_TIMEOUT 	
	MEMBER READ_UNLOCK_TIMEOUT	
	MEMBER WRITE_UNLOCK_TIMEOUT	

	MEMBER CLOSE_FILE 			:= 1140
	MEMBER CLOSE_MEMO 			
	MEMBER CLOSE_ORDER			

	MEMBER INVALID_ORDER		:= 1150
	MEMBER RECNO_MISSING		
	MEMBER NOORDER				
	MEMBER UNSUPPORTED			



	//
	//	Following errors are known as Clipper's internal errors
	//

	MEMBER WRITE_NTX				:= 1200
	MEMBER KEY_NOT_FOUND			
	MEMBER KEY_EVAL				
	MEMBER VAR_TYPE				

	MEMBER READ_BUFFER			    := 1206
	MEMBER SORT_INIT				
	MEMBER SORT_ADVANCE			    
	MEMBER SORT_SORT				
	MEMBER SORT_COMPLETE			
	MEMBER SORT_END				
	MEMBER READ_TEMPFILE			
	MEMBER STREAM_NUM 			    
	MEMBER CREATE_TEMPFILE		    

	MEMBER DISKIO_WRITE				:= 1216
	MEMBER WRONG_DRIVERTYPE		
	MEMBER OUTOFMEMORY			
	MEMBER INVALIDARG 			
	MEMBER USER                     := 2000
  
END ENUM


END NAMESPACE

#region Defines
define ERDD_OPEN_FILE		    := ERDD.OPEN_FILE		    
define ERDD_OPEN_MEMO		    := ERDD.OPEN_MEMO		    
define ERDD_OPEN_ORDER 		    := ERDD.OPEN_ORDER 		    
define ERDD_CREATE_FILE		    := ERDD.CREATE_FILE		    
define ERDD_CREATE_MEMO		    := ERDD.CREATE_MEMO		    
define ERDD_CREATE_ORDER	    := ERDD.CREATE_ORDER	    
define ERDD_READ			    := ERDD.READ			    
define ERDD_WRITE			    := ERDD.WRITE			    
define ERDD_CORRUPT			    := ERDD.CORRUPT			    
define ERDD_CORRUPT_HEADER 	    := ERDD.CORRUPT_HEADER 	    
define ERDD_RDDVERSION 		    := ERDD.RDDVERSION 		    
define ERDD_DATATYPE		    := ERDD.DATATYPE		    
define ERDD_DATAWIDTH		    := ERDD.DATAWIDTH		    
define ERDD_UNLOCKED		    := ERDD.UNLOCKED		    
define ERDD_SHARED 			    := ERDD.SHARED 			    
define ERDD_APPENDLOCK 		    := ERDD.APPENDLOCK 		    
define ERDD_READONLY		    := ERDD.READONLY		    
define ERDD_NULLKEY			    := ERDD.NULLKEY			    
define ERDD_NTXLIMIT		    := ERDD.NTXLIMIT		    
define ERDD_TAGLIMIT		    := ERDD.TAGLIMIT		    
define ERDD_INIT_LOCK		    := ERDD.INIT_LOCK		    
define ERDD_READ_LOCK		    := ERDD.READ_LOCK		    
define ERDD_WRITE_LOCK 		    := ERDD.WRITE_LOCK 		    
define ERDD_READ_UNLOCK		    := ERDD.READ_UNLOCK		    
define ERDD_WRITE_UNLOCK	    := ERDD.WRITE_UNLOCK	    
define ERDD_READ_LOCK_TIMEOUT   := ERDD.READ_LOCK_TIMEOUT    
define ERDD_WRITE_LOCK_TIMEOUT  := ERDD.WRITE_LOCK_TIMEOUT    
define ERDD_READ_UNLOCK_TIMEOUT := ERDD.READ_UNLOCK_TIMEOUT    
define ERDD_WRITE_UNLOCK_TIMEOUT:= ERDD.WRITE_UNLOCK_TIMEOUT    
define ERDD_CLOSE_FILE 		    := ERDD.CLOSE_FILE 		    
define ERDD_CLOSE_MEMO 		    := ERDD.CLOSE_MEMO 		    
define ERDD_CLOSE_ORDER		    := ERDD.CLOSE_ORDER		    
define ERDD_INVALID_ORDER	    := ERDD.INVALID_ORDER	    
define ERDD_RECNO_MISSING	    := ERDD.RECNO_MISSING	    
define ERDD_NOORDER			    := ERDD.NOORDER			    
define ERDD_UNSUPPORTED		    := ERDD.UNSUPPORTED		    
define ERDD_WRITE_NTX		    := ERDD.WRITE_NTX		    
define ERDD_KEY_NOT_FOUND	    := ERDD.KEY_NOT_FOUND	    
define ERDD_KEY_EVAL		    := ERDD.KEY_EVAL		    
define ERDD_VAR_TYPE		    := ERDD.VAR_TYPE		    
define ERDD_READ_BUFFER		    := ERDD.READ_BUFFER		    
define ERDD_SORT_INIT		    := ERDD.SORT_INIT		    
define ERDD_SORT_ADVANCE	    := ERDD.SORT_ADVANCE	    
define ERDD_SORT_SORT		    := ERDD.SORT_SORT		    
define ERDD_SORT_COMPLETE	    := ERDD.SORT_COMPLETE	    
define ERDD_SORT_END		    := ERDD.SORT_END		    
define ERDD_READ_TEMPFILE	    := ERDD.READ_TEMPFILE	    
define ERDD_STREAM_NUM 		    := ERDD.STREAM_NUM 		    
define ERDD_CREATE_TEMPFILE	    := ERDD.CREATE_TEMPFILE	    
define DISKIO_WRITE			    := ERDD.DISKIO_WRITE			    
define ERDD_WRONG_DRIVERTYPE    := ERDD.WRONG_DRIVERTYPE    
define ERDD_OUTOFMEMORY		    := ERDD.OUTOFMEMORY		    
define ERDD_INVALIDARG 		    := ERDD.INVALIDARG 		    
define ERDD_USER				:= ERDD.USER					
#endregion