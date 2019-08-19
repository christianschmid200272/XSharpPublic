//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//

/// <summary>Creates an object from a class definition or an Automation-enabled application.</summary>
/// <param name="cClassName">Specifies the class or OLE object from which the new object is created.</param>
/// <param name="_args">These optional parameters are used to pass values to the Init event procedure for the class.
/// The Init event is executed when you issue CREATEOBJECT( ) and allows you to initialize the object.</param>
/// <returns>The object that was created</returns>
/// <seealso cref='M:XSharp.RT.Functions.CreateInstance(XSharp.__Usual,XSharp.__Usual)' >CreateInstance</seealso>

FUNCTION CreateObject(cClassName, _args ) AS OBJECT CLIPPER
    // The pseudo function _ARGS() returns the Clipper arguments array
    RETURN CreateInstance(_ARGS())


PROCEDURE RddInit() AS VOID _INIT3
    // Make sure that the VFP dialect has the DBFVFP driver as default RDD
    RddSetDefault("DBFVFP")
    RuntimeState.SetValue(Set.FOXCOLLATE,"")
    RuntimeState.SetValue(Set.MEMOWIDTH, 50)
    RuntimeState.SetValue(Set.NEAR, FALSE)
    RuntimeState.SetValue(Set.SQLANSI, FALSE)
    RETURN 



Function SetFoxCollation(cCollation as STRING) AS STRING
local cOld := RuntimeState.GetValue<STRING>(Set.FOXCOLLATE) AS STRING
local aAllowed as STRING[]
LOCAL lOk := FALSE as LOGIC
LOCAL cValue := cCollation as STRING
aAllowed := System.Enum.GetNames(typeof(XSharp.FoxCollations))
cValue := cValue:Trim():ToUpper()
FOREACH VAR cEnum in aAllowed
    IF String.Compare(cValue, cEnum, StringComparison.OrdinalIgnoreCase) == 0
        lOk := TRUE
        EXIT
    ENDIF
NEXT
IF lOk
    RuntimeState.SetValue(Set.FOXCOLLATE,cValue)
ELSE
    local oError as Error
    oError := Error.ArgumentError(__FUNCTION__, nameof(cCollation), 1, {cCollation})
    oError:Description := "Collating sequence '"+cCollation+"' is not found"
    oError:Throw()
ENDIF
RETURN cOld
