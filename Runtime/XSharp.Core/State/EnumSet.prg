﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
USING XSharp
BEGIN NAMESPACE XSharp
	/// <summary>Values that match the Visual Objects SET_* defines </summary>
	ENUM SET
		MEMBER EXACT       := 1			// LOGIC
		MEMBER FIXED	   := 2			// LOGIC
		MEMBER DECIMALS    := 3			// INT
		MEMBER DATEFORMAT  := 4			// STRING
		MEMBER EPOCH       := 5			// INT
		MEMBER PATH        := 6			// STRING
		MEMBER DEFAULT	   := 7			// STRING
		MEMBER EXCLUSIVE   := 8			// LOGIC
		MEMBER SOFTSEEK    := 9			// LOGIC
		MEMBER UNIQUE      := 10		// LOGIC
		MEMBER DELETED     := 11		// LOGIC
		MEMBER CANCEL      := 12		// LOGIC
		MEMBER @@DEBUG     := 13	
		MEMBER TYPEAHEAD   := 14		// INT
		MEMBER COLOR       := 15		// STRING
		MEMBER CURSOR      := 16		// INT
		MEMBER CONSOLE     := 17		// LOGIC
		MEMBER ALTERNATE   := 18		// LOGIC
		MEMBER ALTFILE     := 19		// STRING
		MEMBER DEVICE      := 20		// STRING
		MEMBER EXTRA       := 21		// LOGIC
		MEMBER EXTRAFILE   := 22		// STRING
		MEMBER PRINTER     := 23		// LOGIC
		MEMBER PRINTFILE   := 24		// STRING
		MEMBER MARGIN      := 25		// INT
		MEMBER BELL        := 26		// LOGIC
		MEMBER CONFIRM     := 27		// LOGIC
		MEMBER ESCAPE      := 28		// LOGIC
		MEMBER INSERT      := 29		// LOGIC
		MEMBER @@EXIT      := 30		// LOGIC
		MEMBER INTENSITY   := 31		// LOGIC
		MEMBER SCOREBOARD  := 32		// LOGIC
		MEMBER DELIMITERS  := 33		// STRING
		MEMBER DELIMCHARS  := 34		// STRING
		MEMBER WRAP        := 35		// LOGIC
		MEMBER MESSAGE     := 36		// INT
		MEMBER MCENTER     := 37		// LOGIC
		MEMBER SCROLLBREAK := 38		// LOGIC
		MEMBER ERRRORLOG   := 39		// LOGIC

		MEMBER NETERR      	:= 40	// LOGIC
		MEMBER DIGITS      	:= 41	// INT   
		MEMBER AMEXT		:= 42	// STRING
		MEMBER PMEXT	    := 43	// STRING
		MEMBER @@ANSI      	:= 44	// LOGIC 
		MEMBER YIELD     	:= 45	// LOGIC 
		MEMBER LOCKTRIES   	:= 46	// INT   
		MEMBER AMPM		    := 47	// LOGIC
		MEMBER CENTURY	    := 48	// LOGIC
		MEMBER DIGITFIXED  	:= 49	// LOGIC
		MEMBER DECIMALSEP  	:= 50	// INT
		MEMBER THOUSANDSEP 	:= 51	// INT
		MEMBER TIMESEP     	:= 52	// INT
		MEMBER FIELDSTORE  	:= 53
		MEMBER SCIENCE     	:= 54	// LOGIC
		MEMBER CPU			:= 55	// INT
		MEMBER FLOATDELTA	:= 56	// System.Double
		MEMBER MATH			:= 57	// INT
		MEMBER INTERNATIONAL:= 58	// STRING
		MEMBER DATECOUNTRY  := 59	// INT
		// 65 - 97 unused

		// X# helper state
		MEMBER EpochCent   := 70		// Numeric
		MEMBER EpochYear   := 71		// Numeric
		MEMBER DateFormatNet := 72		// String
		MEMBER DateFormatEmpty := 73    // String
		MEMBER OPTIONVO11	:= 74	// Logic
		MEMBER OPTIONOVF	:= 75	// Logic
		MEMBER NOMETHOD		:= 76	// STRING
		MEMBER APPMODULE	:= 77	// System.Reflection.Module
		MEMBER PATHARRAY    := 78	// String[]
		MEMBER NatDLL		:= 79   // string
		MEMBER CollationTable := 80  // byte[]
		MEMBER ErrorLevel   := 81  // DWORD
		MEMBER ErrorBlock   := 82  // CodeBlock
        MEMBER OPTIONVO13	:= 83	// Logic
        MEMBER LastRddError := 84   // Exception object
		MEMBER DICT        := 98	// LOGIC
		MEMBER INTL        := 99	// LOGIC

		// Vulcan RDDInfo Settings
		MEMBER RDDINFO		:= 100
		MEMBER MEMOBLOCKSIZE:= 101		// INT
		MEMBER DEFAULTRDD	:= 102		// STRING
		MEMBER MEMOEXT	    := 103		// STRING
		MEMBER AUTOOPEN     := 104		// LOGIC
		MEMBER AUTOORDER    := 105		// LOGIC
		MEMBER HPLOCKING    := 106      // LOGIC 
		MEMBER NEWINDEXLOCK := 107      // LOGIC 
		MEMBER AUTOSHARE    := 108		// LOGIC
		MEMBER STRICTREAD   := 109		// LOGIC
		MEMBER BLOBCIRCREF	:= 110		// LOGIC
		MEMBER OPTIMIZE     := 111		// LOGIC
		MEMBER FOXLOCK      := 112		// LOGIC
		MEMBER WINCODEPAGE	:= 113		// Numeric
		MEMBER DOSCODEPAGE	:= 114		// Numeric
		MEMBER COLLATIONMODE:= 115		// COLLATIONMODE (STRING)
		
		// Advantage extensions
		MEMBER AXSLOCKING           := 150
		MEMBER RIGHTSCHECKING       := 151
		MEMBER CONNECTION_HANDLE    := 152
		MEMBER EXACTKEYPOS          := 153
		MEMBER SQL_QUERY            := 154
		MEMBER SQL_TABLE_PASSWORDS  := 155
		MEMBER COLLATION_NAME       := 156

		// 100 - 117 Harbour extensions
		MEMBER LANGUAGE       :=  180  
		MEMBER IDLEREPEAT     :=  181 
		MEMBER FILECASE       :=  182			
		MEMBER DIRCASE        :=  183 
		MEMBER DIRSEPARATOR   :=  184 
		MEMBER EOF            :=  185 
		MEMBER HARDCOMMIT     :=  186 
		MEMBER FORCEOPT       :=  187 
		MEMBER DBFLOCKSCHEME  :=  188 
		MEMBER DEFEXTENSIONS  :=  189 
		MEMBER EOL            :=  190 
		MEMBER TRIMFILENAME   :=  191	
		MEMBER HBOUTLOG       :=  192 
		MEMBER HBOUTLOGINFO   :=  193 
		MEMBER CODEPAGE       :=  194				// Map to Vulcan setting ?
		MEMBER OSCODEPAGE     :=  195				// Map to Vulcan setting ?
		MEMBER TIMEFORMAT     :=  196			
		MEMBER DBCODEPAGE     :=  197				// Map to Vulcan setting ?
		
		// Start of user values
		MEMBER User           := 200
		
	END ENUM
END NAMESPACE
#region Defines
DEFINE _SET_EXACT       := Set.Exact		
DEFINE _SET_FIXED       := Set.Fixed 		
DEFINE _SET_DECIMALS    := Set.Decimals		
DEFINE _SET_DATEFORMAT  := Set.DATEFORMAT  	
DEFINE _SET_EPOCH       := Set.EPOCH       	
DEFINE _SET_PATH        := Set.PATH        	
DEFINE _SET_DEFAULT     := Set.DEFAULT     	
	
DEFINE _SET_EXCLUSIVE   := Set.EXCLUSIVE   	
DEFINE _SET_SOFTSEEK    := Set.SOFTSEEK    	
DEFINE _SET_UNIQUE      := Set.UNIQUE      	
DEFINE _SET_DELETED     := Set.DELETED     	
	
DEFINE _SET_CANCEL      := Set.CANCEL
DEFINE _SET_DEBUG       := Set.DEBUG       	
DEFINE _SET_TYPEAHEAD   := Set.TYPEAHEAD   	
	
DEFINE _SET_COLOR       := Set.COLOR       	
DEFINE _SET_CURSOR      := Set.CURSOR      	
DEFINE _SET_CONSOLE     := Set.CONSOLE     	
DEFINE _SET_ALTERNATE   := Set.ALTERNATE   	
DEFINE _SET_ALTFILE     := Set.ALTFILE     	
DEFINE _SET_DEVICE      := Set.DEVICE      	
DEFINE _SET_EXTRA       := Set.EXTRA       	
DEFINE _SET_EXTRAFILE   := Set.EXTRAFILE   	
DEFINE _SET_PRINTER     := Set.PRINTER     	
DEFINE _SET_PRINTFILE   := Set.PRINTFILE   	
DEFINE _SET_MARGIN      := Set.MARGIN      	
	
DEFINE _SET_BELL        := Set.BELL        	
DEFINE _SET_CONFIRM     := Set.CONFIRM     	
DEFINE _SET_ESCAPE      := Set.ESCAPE      	
DEFINE _SET_INSERT      := Set.INSERT      	
DEFINE _SET_EXIT        := Set.EXIT        	
DEFINE _SET_INTENSITY   := Set.INTENSITY   	
DEFINE _SET_SCOREBOARD  := Set.SCOREBOARD  	
DEFINE _SET_DELIMITERS  := Set.DELIMITERS  	
DEFINE _SET_DELIMCHARS  := Set.DELIMCHARS  	
	
DEFINE _SET_WRAP        := Set.WRAP        	
DEFINE _SET_MESSAGE     := Set.MESSAGE     	
DEFINE _SET_MCENTER     := Set.MCENTER     	
DEFINE _SET_SCROLLBREAK := Set.SCROLLBREAK 	

// 48 and 49 unused
DEFINE _SET_DIGITS      	:= Set.DIGITS      
DEFINE _SET_NETERR      	:= Set.NETERR      
DEFINE _SET_ANSI      		:= Set.ANSI      
DEFINE _SET_YIELD     		:= Set.YIELD     
DEFINE _SET_LOCKTRIES   	:= Set.LOCKTRIES   
DEFINE _SET_AMEXT			:= Set.AMEXT		
DEFINE _SET_AMPM			:= Set.AMPM		   
DEFINE _SET_PMEXT	    	:= Set.PMEXT	   
DEFINE _SET_CENTURY	    	:= Set.CENTURY	   
DEFINE _SET_DIGITFIXED  	:= Set.DIGITFIXED  
DEFINE _SET_DECIMALSEP  	:= Set.DECIMALSEP  
DEFINE _SET_THOUSANDSEP 	:= Set.THOUSANDSEP 
DEFINE _SET_TIMESEP     	:= Set.TIMESEP     
DEFINE _SET_FIELDSTORE  	:= Set.FIELDSTORE  
DEFINE _SET_SCIENCE     	:= Set.SCIENCE     
DEFINE _SET_CPU				:= Set.CPU			
DEFINE _SET_FLOATDELTA		:= Set.FLOATDELTA	
DEFINE _SET_MATH			:= Set.MATH			
DEFINE _SET_INTERNATIONAL	:= Set.INTERNATIONAL
DEFINE _SET_DATECOUNTRY		:= Set.DATECOUNTRY
DEFINE _SET_DICT			:= Set.Dict			
DEFINE _SET_INTL			:= Set.Intl		
	
DEFINE _SET_COLLATIONMODE	:= Set.COLLATIONMODE	

// Vulcan RDDInfo Settings
DEFINE _SET_RDDINFO				:= Set.RDDINFO		
DEFINE _SET_MEMOBLOCKSIZE		:= Set.MEMOBLOCKSIZE
DEFINE _SET_DEFAULTRDD			:= Set.DEFAULTRDD	
DEFINE _SET_MEMOEXT	    		:= Set.MEMOEXT	    
DEFINE _SET_AUTOOPEN    		:= Set.AUTOOPEN     
DEFINE _SET_AUTOORDER   		:= Set.AUTOORDER    
DEFINE _SET_HPLOCKING   		:= Set.HPLOCKING    
DEFINE _SET_NEWINDEXLOCK		:= Set.NEWINDEXLOCK 
DEFINE _SET_AUTOSHARE   		:= Set.AUTOSHARE    
DEFINE _SET_STRICTREAD  		:= Set.STRICTREAD   
DEFINE _SET_BLOBCIRCREF			:= Set.BLOBCIRCREF	
DEFINE _SET_OPTIMIZE    		:= Set.OPTIMIZE     
DEFINE _SET_FOXLOCK     		:= Set.FOXLOCK      
DEFINE _SET_WINCODEPAGE			:= Set.WINCODEPAGE	
DEFINE _SET_DOSCODEPAGE			:= Set.DOSCODEPAGE	

// Harbour extensions
DEFINE _SET_LANGUAGE       :=  Set.LANGUAGE      	
DEFINE _SET_IDLEREPEAT     :=  Set.IDLEREPEAT    	
DEFINE _SET_FILECASE       :=  Set.FILECASE      	
DEFINE _SET_DIRCASE        :=  Set.DIRCASE       	
DEFINE _SET_DIRSEPARATOR   :=  Set.DIRSEPARATOR  	
DEFINE _SET_EOF            :=  Set.EOF           	
DEFINE _SET_HARDCOMMIT     :=  Set.HARDCOMMIT    	
DEFINE _SET_FORCEOPT       :=  Set.FORCEOPT      	
DEFINE _SET_DBFLOCKSCHEME  :=  Set.DBFLOCKSCHEME 	
DEFINE _SET_DEFEXTENSIONS  :=  Set.DEFEXTENSIONS 	
DEFINE _SET_EOL            :=  Set.EOL           	
DEFINE _SET_TRIMFILENAME   :=  Set.TRIMFILENAME  	
DEFINE _SET_HBOUTLOG       :=  Set.HBOUTLOG      	
DEFINE _SET_HBOUTLOGINFO   :=  Set.HBOUTLOGINFO  	
DEFINE _SET_CODEPAGE       :=  Set.CODEPAGE      	
DEFINE _SET_OSCODEPAGE     :=  Set.OSCODEPAGE    	
DEFINE _SET_TIMEFORMAT     :=  Set.TIMEFORMAT    	
DEFINE _SET_DBCODEPAGE     :=  Set.DBCODEPAGE    	
	
// Advantage additions
DEFINE _SET_AXSLOCKING           := Set.AXSLOCKING         
DEFINE _SET_RIGHTSCHECKING       := Set.RIGHTSCHECKING     
DEFINE _SET_CONNECTION_HANDLE    := Set.CONNECTION_HANDLE  
DEFINE _SET_EXACTKEYPOS          := Set.EXACTKEYPOS        
DEFINE _SET_SQL_QUERY            := Set.SQL_QUERY          
DEFINE _SET_SQL_TABLE_PASSWORDS  := Set.SQL_TABLE_PASSWORDS
DEFINE _SET_COLLATION_NAME       := Set.COLLATION_NAME     
	
#endregion

