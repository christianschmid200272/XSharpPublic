﻿CLASS Customer INHERIT DBSERVER
	INSTANCE cDBFPath	  := "c:\cavo28SP3\Samples\GSTUTOR\" AS STRING
	INSTANCE cName		  := "Customer.dbf" AS STRING
	INSTANCE xDriver	  := "SQLRDD"		 AS USUAL 	 /// SQLRDD Change
	INSTANCE lReadOnlyMode:= .F.		 AS LOGIC
	INSTANCE lSharedMode  := NIL	 AS USUAL
	INSTANCE nOrder 	  := 1	 AS INT
	//USER CODE STARTS HERE (do NOT remove this line)

ACCESS  ADDRESS

    RETURN SELF:FieldGet(#ADDRESS)
ASSIGN  ADDRESS(uValue)

    RETURN SELF:FieldPut(#ADDRESS, uValue)


ACCESS  CITY

    RETURN SELF:FieldGet(#CITY)
ASSIGN  CITY(uValue)

    RETURN SELF:FieldPut(#CITY, uValue)


ACCESS  CUSTNUM

    RETURN SELF:FieldGet(#CUSTNUM)
ASSIGN  CUSTNUM(uValue)

    RETURN SELF:FieldPut(#CUSTNUM, uValue)


ACCESS  FAX

    RETURN SELF:FieldGet(#FAX)
ASSIGN  FAX(uValue)

    RETURN SELF:FieldPut(#FAX, uValue)


ACCESS FieldDesc
	//
	//	Describes all fields selected by DBServer-Editor
	//
	LOCAL aRet		AS ARRAY
	LOCAL nFields	AS DWORD

	nFields := 9

	IF nFields > 0
		aRet := ArrayCreate(nFields)

		//
		//	The following code creates an array of field
		//	descriptors with these items for each
		//	selected field:
		//
		//	{ <symFieldName>, <cFieldName>, <oFieldSpec> }
		//
		//	Use following predefined constants to access
		//	each subarray:
		//
		//	DBC_SYMBOL
		//	DBC_NAME
		//	DBC_FIELDSPEC
		//

		aRet[1] := { #CUSTNUM, "CUSTNUM",  Customer_CUSTNUM{}}
		aRet[2] := { #FIRSTNAME, "FIRSTNAME",  Customer_FIRSTNAME{}}
		aRet[3] := { #LASTNAME, "LASTNAME",  Customer_LASTNAME{}}
		aRet[4] := { #ADDRESS, "ADDRESS",  Customer_ADDRESS{}}
		aRet[5] := { #CITY, "CITY",  Customer_CITY{}}
		aRet[6] := { #STATE, "STATE",  Customer_STATE{}}
		aRet[7] := { #ZIP, "ZIP",  Customer_ZIP{}}
		aRet[8] := { #PHONE, "PHONE",  Customer_PHONE{}}
		aRet[9] := { #FAX, "FAX",  Customer_FAX{}}

	ELSE
		aRet := {}
	ENDIF


	RETURN aRet
ACCESS  FIRSTNAME

    RETURN SELF:FieldGet(#FIRSTNAME)
ASSIGN  FIRSTNAME(uValue)

    RETURN SELF:FieldPut(#FIRSTNAME, uValue)


ACCESS IndexList
	//
	//	Describes all index files created or selected
	//	by DBServer-Editor
	//
	LOCAL aRet			AS ARRAY
	LOCAL nIndexCount	AS DWORD

	nIndexCount := 1

	IF nIndexCount > 0
		aRet := ArrayCreate(nIndexCount)

		//
		//	The following code creates an array of index
		//	file descriptors with these items for each
		//	selected index file:
		//
		//	{ <cFileName>, <cPathName>, <aOrders> }
		//
		//	Use following predefined constants to access
		//	each subarray:
		//
		//	DBC_INDEXNAME
		//	DBC_INDEXPATH
		//	DBC_ORDERS
		//
		//	Array <aOrders> contains an array of
		//	order descriptors with these items for each
		//	order:
		//
		//	{ <cOrder>, <lDuplicates>, <lAscending>, <cKey>, <cFor> }
		//
		//	Use following predefined constants to access
		//	aOrder subarrays:
		//
		//	DBC_TAGNAME
		//	DBC_DUPLICATE
		//	DBC_ASCENDING
		//	DBC_KEYEXP
		//	DBC_FOREXP
		//

		aRet[1] := { "Custname.ntx", "c:\cavo28SP3\Samples\GSTUTOR\",;
 					{{ "Custname", .T., .T., e"lastname + firstname", e"" } } }

	ELSE
		aRet := {}
	ENDIF

	RETURN aRet
CONSTRUCTOR(cDBF, lShare, lRO, xRdd)
	LOCAL oFS		  AS FILESPEC
	LOCAL i 		  AS DWORD
	LOCAL nFields	  AS DWORD
	LOCAL aFieldDesc  AS ARRAY
	LOCAL aIndex	  AS ARRAY
	LOCAL nIndexCount AS DWORD
	LOCAL oFSIndex	  AS FILESPEC
	LOCAL nPos		  AS DWORD
	LOCAL lTemp 	  AS LOGIC
	LOCAL oFSTemp	  AS FILESPEC


	IF IsLogic(lShare)
		SELF:lSharedMode := lShare
	ELSE
		IF !IsLogic(SELF:lSharedMode)
			SELF:lSharedMode := !SetExclusive()
		ENDIF
	ENDIF

	IF IsLogic(lRO)
		SELF:lReadOnlyMode := lRO
	ENDIF

	IF IsString(xRdd)  .OR. IsArray(xRdd)
		SELF:xDriver := xRdd
	ENDIF

	SELF:PreInit()

	IF IsString(cDBF)
		//	UH 01/18/2000
		oFSTemp := FileSpec{SELF:cDBFPath + SELF:cName}
		oFS 	:= FileSpec{cDBF}

		IF SLen(oFS:Drive) = 0
			oFS:Drive := CurDrive()
		ENDIF
		IF SLen(oFS:Path) = 0
			oFS:Path  := "\" + CurDir()
		ENDIF

		IF SLen(oFS:FileName) = 0
			oFS:Filename := SELF:cName
		ENDIF

		IF oFS:FullPath == oFSTemp:Fullpath
			lTemp := .T.
		ELSE
		   IF Left(cDBF, 2) =='\\'  // Unc path, for example \\Server\Share\FileName.DBF
				SELF:cDBFPath := oFS:Path
		   ELSE
				SELF:cDBFPath := oFS:Drive + oFS:Path
		   ENDIF
				SELF:cName := oFS:FileName + oFS:Extension
				oFS := FileSpec{SELF:cDBFPath + SELF:cName}
		ENDIF
	ELSE
		oFS 	 := FileSpec{SELF:cName}
		oFS:Path := SELF:cDBFPath
	ENDIF


	SUPER(oFS, SELF:lSharedMode, SELF:lReadOnlyMode , SELF:xDriver )

	oHyperLabel := HyperLabel{#Customer, "Customer", "", "Customer"}

	IF oHLStatus = NIL
		nFields := ALen(aFieldDesc := SELF:FieldDesc)
		FOR i:=1 UPTO nFields
			nPos := SELF:FieldPos( aFieldDesc[i][DBC_NAME] )

			SELF:SetDataField( nPos,;
				DataField{aFieldDesc[i][DBC_SYMBOL],aFieldDesc[i][DBC_FIELDSPEC]} )

			IF String2Symbol(aFieldDesc[i][DBC_NAME]) != aFieldDesc[i][DBC_SYMBOL]
				SELF:FieldInfo(DBS_ALIAS, nPos, Symbol2String(aFieldDesc[i][DBC_SYMBOL]) )
			ENDIF
		NEXT

		nIndexCount := ALen(aIndex:=SELF:IndexList)

		FOR i:=1 UPTO nIndexCount
			oFSIndex := FileSpec{ aIndex[i][DBC_INDEXNAME] }
			oFSIndex:Path := SELF:cDBFPath

			IF lTemp  .AND. !Empty( aIndex[i][DBC_INDEXPATH] )
				oFSIndex:Path := aIndex[i][DBC_INDEXPATH]
			ENDIF

			IF oFSIndex:Find()
				lTemp := SELF:SetIndex( oFSIndex )
			ENDIF
		NEXT

		//	UH 01/18/2000
		//	SELF:nOrder > 0
		IF lTemp  .AND. SELF:nOrder > 0
         SELF:SetOrder(SELF:nOrder)
	 /// SQLRDD Change - Start
      ELSE
         SELF:SetOrder("CustName")
	 /// SQLRDD Change - End
		ENDIF

		SELF:GoTop()
	ENDIF

	SELF:PostInit()

	RETURN SELF
ACCESS  LASTNAME

    RETURN SELF:FieldGet(#LASTNAME)
ASSIGN  LASTNAME(uValue)

    RETURN SELF:FieldPut(#LASTNAME, uValue)


ACCESS  PHONE

    RETURN SELF:FieldGet(#PHONE)
ASSIGN  PHONE(uValue)

    RETURN SELF:FieldPut(#PHONE, uValue)


ACCESS  STATE

    RETURN SELF:FieldGet(#STATE)
ASSIGN  STATE(uValue)

    RETURN SELF:FieldPut(#STATE, uValue)


ACCESS  ZIP

    RETURN SELF:FieldGet(#ZIP)
ASSIGN  ZIP(uValue)

    RETURN SELF:FieldPut(#ZIP, uValue)


END CLASS
CLASS Customer_ADDRESS INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#ADDRESS, "Address", "", "Customer_ADDRESS" },  "C", 25, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Customer_CITY INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#CITY, "City", "", "Customer_CITY" },  "C", 15, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Customer_CUSTNUM INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#CUSTNUM, "Custnum", "", "Customer_CUSTNUM" },  "N", 5, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Customer_FAX INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#FAX, "Fax", "", "Customer_FAX" },  "C", 13, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Customer_FIRSTNAME INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#FIRSTNAME, "Firstname", "", "Customer_FIRSTNAME" },  "C", 10, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Customer_LASTNAME INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#LASTNAME, "Lastname", "", "Customer_LASTNAME" },  "C", 10, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Customer_PHONE INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#PHONE, "Phone", "", "Customer_PHONE" },  "C", 13, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Customer_STATE INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#STATE, "State", "", "Customer_STATE" },  "C", 2, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Customer_ZIP INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#ZIP, "Zip", "", "Customer_ZIP" },  "C", 5, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Orders INHERIT DBSERVER
	INSTANCE cDBFPath	  := "c:\cavo28SP3\Samples\GSTUTOR\" AS STRING
	INSTANCE cName		  := "Orders.dbf" AS STRING
	INSTANCE xDriver	  := "SQLRDD"		 AS USUAL 	 /// SQLRDD Change
	INSTANCE lReadOnlyMode:= .F.		 AS LOGIC
	INSTANCE lSharedMode  := .F.	 AS USUAL
	INSTANCE nOrder 	  := 1	 AS INT
	//USER CODE STARTS HERE (do NOT remove this line)

ACCESS  CUSTNUM

    RETURN SELF:FieldGet(#CUSTNUM)
ASSIGN  CUSTNUM(uValue)

    RETURN SELF:FieldPut(#CUSTNUM, uValue)


ACCESS FieldDesc
	//
	//	Describes all fields selected by DBServer-Editor
	//
	LOCAL aRet		AS ARRAY
	LOCAL nFields	AS DWORD

	nFields := 10

	IF nFields > 0
		aRet := ArrayCreate(nFields)

		//
		//	The following code creates an array of field
		//	descriptors with these items for each
		//	selected field:
		//
		//	{ <symFieldName>, <cFieldName>, <oFieldSpec> }
		//
		//	Use following predefined constants to access
		//	each subarray:
		//
		//	DBC_SYMBOL
		//	DBC_NAME
		//	DBC_FIELDSPEC
		//

		aRet[1] := { #CUSTNUM, "CUSTNUM",  Orders_CUSTNUM{}}
		aRet[2] := { #ORDERNUM, "ORDERNUM",  Orders_ORDERNUM{}}
		aRet[3] := { #ORDER_DATE, "ORDER_DATE",  Orders_ORDER_DATE{}}
		aRet[4] := { #SHIP_DATE, "SHIP_DATE",  Orders_SHIP_DATE{}}
		aRet[5] := { #SHIP_ADDRS, "SHIP_ADDRS",  Orders_SHIP_ADDRS{}}
		aRet[6] := { #SHIP_CITY, "SHIP_CITY",  Orders_SHIP_CITY{}}
		aRet[7] := { #SHIP_STATE, "SHIP_STATE",  Orders_SHIP_STATE{}}
		aRet[8] := { #SHIP_ZIP, "SHIP_ZIP",  Orders_SHIP_ZIP{}}
		aRet[9] := { #ORDERPRICE, "ORDERPRICE",  Orders_ORDERPRICE{}}
		aRet[10] := { #SELLER_ID, "SELLER_ID",  Orders_SELLER_ID{}}

	ELSE
		aRet := {}
	ENDIF


	RETURN aRet
ACCESS IndexList
	//
	//	Describes all index files created or selected
	//	by DBServer-Editor
	//
	LOCAL aRet			AS ARRAY
	LOCAL nIndexCount	AS DWORD

	nIndexCount := 1

	IF nIndexCount > 0
		aRet := ArrayCreate(nIndexCount)

		//
		//	The following code creates an array of index
		//	file descriptors with these items for each
		//	selected index file:
		//
		//	{ <cFileName>, <cPathName>, <aOrders> }
		//
		//	Use following predefined constants to access
		//	each subarray:
		//
		//	DBC_INDEXNAME
		//	DBC_INDEXPATH
		//	DBC_ORDERS
		//
		//	Array <aOrders> contains an array of
		//	order descriptors with these items for each
		//	order:
		//
		//	{ <cOrder>, <lDuplicates>, <lAscending>, <cKey>, <cFor> }
		//
		//	Use following predefined constants to access
		//	aOrder subarrays:
		//
		//	DBC_TAGNAME
		//	DBC_DUPLICATE
		//	DBC_ASCENDING
		//	DBC_KEYEXP
		//	DBC_FOREXP
		//

		aRet[1] := { "Ordcust.ntx", "c:\cavo28SP3\Samples\GSTUTOR\",;
 					{{ "Ordcust", .T., .T., e"custnum", e"" } } }

	ELSE
		aRet := {}
	ENDIF

	RETURN aRet
CONSTRUCTOR(cDBF, lShare, lRO, xRdd)
	LOCAL oFS		  AS FILESPEC
	LOCAL i 		  AS DWORD
	LOCAL nFields	  AS DWORD
	LOCAL aFieldDesc  AS ARRAY
	LOCAL aIndex	  AS ARRAY
	LOCAL nIndexCount AS DWORD
	LOCAL oFSIndex	  AS FILESPEC
	LOCAL nPos		  AS DWORD
	LOCAL lTemp 	  AS LOGIC
	LOCAL oFSTemp	  AS FILESPEC


	IF IsLogic(lShare)
		SELF:lSharedMode := lShare
	ELSE
		IF !IsLogic(SELF:lSharedMode)
			SELF:lSharedMode := !SetExclusive()
		ENDIF
	ENDIF

	IF IsLogic(lRO)
		SELF:lReadOnlyMode := lRO
	ENDIF

	IF IsString(xRdd)  .OR. IsArray(xRdd)
		SELF:xDriver := xRdd
	ENDIF

	SELF:PreInit()

	IF IsString(cDBF)
		//	UH 01/18/2000
		oFSTemp := FileSpec{SELF:cDBFPath + SELF:cName}
		oFS 	:= FileSpec{cDBF}

		IF SLen(oFS:Drive) = 0
			oFS:Drive := CurDrive()
		ENDIF
		IF SLen(oFS:Path) = 0
			oFS:Path  := "\" + CurDir()
		ENDIF

		IF SLen(oFS:FileName) = 0
			oFS:Filename := SELF:cName
		ENDIF

		IF oFS:FullPath == oFSTemp:Fullpath
			lTemp := .T.
		ELSE
		   IF Left(cDBF, 2) =='\\'  // Unc path, for example \\Server\Share\FileName.DBF
				SELF:cDBFPath := oFS:Path
		   ELSE
				SELF:cDBFPath := oFS:Drive + oFS:Path
		   ENDIF
				SELF:cName := oFS:FileName + oFS:Extension
				oFS := FileSpec{SELF:cDBFPath + SELF:cName}
		ENDIF
	ELSE
		oFS 	 := FileSpec{SELF:cName}
		oFS:Path := SELF:cDBFPath
	ENDIF


	SUPER(oFS, SELF:lSharedMode, SELF:lReadOnlyMode , SELF:xDriver )

	oHyperLabel := HyperLabel{#Orders, "Orders", "", "Orders"}

	IF oHLStatus = NIL
		nFields := ALen(aFieldDesc := SELF:FieldDesc)
		FOR i:=1 UPTO nFields
			nPos := SELF:FieldPos( aFieldDesc[i][DBC_NAME] )

			SELF:SetDataField( nPos,;
				DataField{aFieldDesc[i][DBC_SYMBOL],aFieldDesc[i][DBC_FIELDSPEC]} )

			IF String2Symbol(aFieldDesc[i][DBC_NAME]) != aFieldDesc[i][DBC_SYMBOL]
				SELF:FieldInfo(DBS_ALIAS, nPos, Symbol2String(aFieldDesc[i][DBC_SYMBOL]) )
			ENDIF
		NEXT

		nIndexCount := ALen(aIndex:=SELF:IndexList)

		FOR i:=1 UPTO nIndexCount
			oFSIndex := FileSpec{ aIndex[i][DBC_INDEXNAME] }
			oFSIndex:Path := SELF:cDBFPath

			IF lTemp  .AND. !Empty( aIndex[i][DBC_INDEXPATH] )
				oFSIndex:Path := aIndex[i][DBC_INDEXPATH]
			ENDIF

			IF oFSIndex:Find()
				lTemp := SELF:SetIndex( oFSIndex )
			ENDIF
		NEXT

		//	UH 01/18/2000
		//	SELF:nOrder > 0
		IF lTemp  .AND. SELF:nOrder > 0
         SELF:SetOrder(SELF:nOrder)
	 	 /// SQLRDD Change - Start
      ELSE
         SELF:SetOrder("OrdCust")
	 	 /// SQLRDD Change - Stop
		ENDIF

		SELF:GoTop()
	ENDIF

	SELF:PostInit()

	RETURN SELF
ACCESS  ORDER_DATE

    RETURN SELF:FieldGet(#ORDER_DATE)
ASSIGN  ORDER_DATE(uValue)

    RETURN SELF:FieldPut(#ORDER_DATE, uValue)


ACCESS  ORDERNUM

    RETURN SELF:FieldGet(#ORDERNUM)
ASSIGN  ORDERNUM(uValue)

    RETURN SELF:FieldPut(#ORDERNUM, uValue)


ACCESS  ORDERPRICE

    RETURN SELF:FieldGet(#ORDERPRICE)
ASSIGN  ORDERPRICE(uValue)

    RETURN SELF:FieldPut(#ORDERPRICE, uValue)


ACCESS  SELLER_ID

    RETURN SELF:FieldGet(#SELLER_ID)
ASSIGN  SELLER_ID(uValue)

    RETURN SELF:FieldPut(#SELLER_ID, uValue)


ACCESS  SHIP_ADDRS

    RETURN SELF:FieldGet(#SHIP_ADDRS)
ASSIGN  SHIP_ADDRS(uValue)

    RETURN SELF:FieldPut(#SHIP_ADDRS, uValue)


ACCESS  SHIP_CITY

    RETURN SELF:FieldGet(#SHIP_CITY)
ASSIGN  SHIP_CITY(uValue)

    RETURN SELF:FieldPut(#SHIP_CITY, uValue)


ACCESS  SHIP_DATE

    RETURN SELF:FieldGet(#SHIP_DATE)
ASSIGN  SHIP_DATE(uValue)

    RETURN SELF:FieldPut(#SHIP_DATE, uValue)


ACCESS  SHIP_STATE

    RETURN SELF:FieldGet(#SHIP_STATE)
ASSIGN  SHIP_STATE(uValue)

    RETURN SELF:FieldPut(#SHIP_STATE, uValue)


ACCESS  SHIP_ZIP

    RETURN SELF:FieldGet(#SHIP_ZIP)
ASSIGN  SHIP_ZIP(uValue)

    RETURN SELF:FieldPut(#SHIP_ZIP, uValue)


END CLASS
CLASS Orders_CUSTNUM INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#CUSTNUM, "Custnum", "", "Orders_CUSTNUM" },  "N", 5, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Orders_ORDER_DATE INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#ORDER_DATE, "Order Date", "", "Orders_ORDER_DATE" },  "D", 8, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Orders_ORDERNUM INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#ORDERNUM, "Ordernum", "", "Orders_ORDERNUM" },  "N", 5, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Orders_ORDERPRICE INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#ORDERPRICE, "Orderprice", "", "Orders_ORDERPRICE" },  "N", 10, 2 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Orders_SELLER_ID INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#SELLER_ID, "Seller Id", "", "Orders_SELLER_ID" },  "C", 5, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Orders_SHIP_ADDRS INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#SHIP_ADDRS, "Ship Addrs", "", "Orders_SHIP_ADDRS" },  "C", 25, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Orders_SHIP_CITY INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#SHIP_CITY, "Ship City", "", "Orders_SHIP_CITY" },  "C", 15, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Orders_SHIP_DATE INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#SHIP_DATE, "Ship Date", "", "Orders_SHIP_DATE" },  "D", 8, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Orders_SHIP_STATE INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#SHIP_STATE, "Ship State", "", "Orders_SHIP_STATE" },  "C", 2, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF
END CLASS
CLASS Orders_SHIP_ZIP INHERIT FIELDSPEC
	//USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR()
    LOCAL   cPict                   AS STRING

    SUPER( HyperLabel{#SHIP_ZIP, "Ship Zip", "", "Orders_SHIP_ZIP" },  "C", 5, 0 )
    cPict       := ""
    IF SLen(cPict) > 0
        SELF:Picture := cPict
    ENDIF

    RETURN SELF

END CLASS
