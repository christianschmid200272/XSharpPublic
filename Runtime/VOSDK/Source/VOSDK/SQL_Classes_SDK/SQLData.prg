/// <include file="SQL.xml" path="doc/SQLData/*" />
CLASS SQLData
	EXPORT @@Null 			AS LOGIC
	EXPORT ValueChanged 	AS LOGIC
	EXPORT Length			AS DWORD
	EXPORT ptrValue		AS PTR
	EXPORT ptrLength		AS PTR
	EXPORT LongValue		AS STRING
	EXPORT HasValue      AS LOGIC


/// <include file="SQL.xml" path="doc/SQLData.Clear/*" />
	METHOD Clear() AS VOID STRICT 
	IF SELF:ptrValue != NULL_PTR
		MemClear(SELF:ptrValue, SELF:Length)
	ENDIF
	IF SELF:ptrLength != NULL_PTR
		LONGINT(ptrLength) := LONGINT(SELF:Length)
	ENDIF
	RETURN


/// <include file="SQL.xml" path="doc/SQLData.ctor/*" />
CONSTRUCTOR() 
    
    
    
    
RETURN 


/// <include file="SQL.xml" path="doc/SQLData.Initialize/*" />
METHOD Initialize( pData AS PTR, pLength AS PTR, nLen AS DWORD, lNull AS LOGIC, lChanged AS LOGIC) AS VOID STRICT 
	SELF:PtrValue 	   := pData
	SELF:ptrLength    := pLength
	SELF:Length 		:= nLen
	SELF:Null 			:= lNull
	SELF:ValueChanged := lChanged
	RETURN
END CLASS


