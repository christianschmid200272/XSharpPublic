
// Class Form  BaseClass   Form  Class  Form
BEGIN NAMESPACE XSharp.VFP.UI
PARTIAL CLASS Form IMPLEMENTS IVFPControl, IVFPOwner
	#include "VFPControl.xh"
	#define NOSET
#include "VFPContainer.xh"
//PROPERTY ACTIVECONTROL AS USUAL AUTO
//PROPERTY ACTIVEFORM AS USUAL AUTO

PROPERTY AllowOutput AS LOGIC AUTO
PROPERTY AlwaysOnBottom AS LOGIC AUTO
PROPERTY AlwaysOnTop  AS LOGIC AUTO
//PROPERTY AUTOCENTER AS USUAL AUTO
//PROPERTY BINDCONTROLS AS USUAL AUTO
METHOD Box(nXCoord1, nYCoord1, nXCoord2, nYCoord2) AS USUAL CLIPPER
RETURN NIL
PROPERTY BufferMode AS LONG AUTO
METHOD Circle (nRadius , nXCoord, nYCoord , nAspect)  AS USUAL CLIPPER
RETURN NIL
PROPERTY ClipControls AS LOGIC AUTO
//PROPERTY CLOSABLE AS USUAL AUTO
METHOD Cls AS USUAL CLIPPER
RETURN NIL
PROPERTY ContinuousScroll AS LOGIC AUTO
//PROPERTY CONTROLBOX AS USUAL AUTO
PROPERTY CurrentX AS LONG AUTO
PROPERTY CurrentY AS LONG AUTO
//PROPERTY DATASESSION AS USUAL AUTO
PROPERTY DataSessionID AS USUAL AUTO
PROPERTY DEClass  AS USUAL AUTO
PROPERTY DEClassLibrary AS USUAL AUTO
PROPERTY DefOLELCID AS LONG AUTO
PROPERTY Desktop  AS LOGIC AUTO
PROPERTY DrawWidth AS LONG AUTO
PROPERTY FillColor AS LONG AUTO
PROPERTY FillStyle AS USUAL AUTO
METHOD GetDockState(aValues) AS LOGIC CLIPPER
RETURN FALSE
PROPERTY HalfHeightCaption AS LOGIC AUTO
PROPERTY HScrollSmallChange AS LONG AUTO
PROPERTY HWND AS USUAL AUTO
//PROPERTY ICON AS USUAL AUTO
//PROPERTY KeyPreview  AS USUAL AUTO
METHOD Line(nXCoord1, nYCoord1, nXCoord2, nYCoord2) AS USUAL CLIPPER
RETURN NIL
PROPERTY LockScreen AS LOGIC AUTO
PROPERTY MacDesktop AS LONG AUTO
//PROPERTY MAXBUTTON AS USUAL AUTO
PROPERTY MaxHeight AS LONG AUTO
PROPERTY MaxLeft  AS LONG AUTO
PROPERTY MaxTop AS LONG AUTO
PROPERTY MaxWidth  AS LONG AUTO
//PROPERTY MDIFORM AS USUAL AUTO
//PROPERTY MINBUTTON AS USUAL AUTO
PROPERTY MinHeight  AS LONG AUTO
PROPERTY MinWidth AS LONG AUTO
//PROPERTY MOVABLE AS USUAL AUTO
PROPERTY Picture AS STRING AUTO
METHOD Point(nXCoord, nYCoord)  AS USUAL CLIPPER
RETURN NIL
METHOD Print(cText, iCurrentX, iCurrentY)  AS USUAL CLIPPER
RETURN NIL
METHOD PSet(nXCoord, nYCoord)  AS USUAL CLIPPER
RETURN NIL
PROPERTY ReleaseType AS LONG AUTO
METHOD SaveAs(cFileName , oDataEnvironment) AS USUAL CLIPPER
RETURN NIL
METHOD SetFocus() AS VOID STRICT
	SELF:Focus()
METHOD SetViewPort(nLeft, nTop) AS USUAL CLIPPER
RETURN NIL
PROPERTY SizeBox  AS LOGIC AUTO
PROPERTY ViewPortHeight AS LONG AUTO
PROPERTY ViewPortLeft AS LONG AUTO
PROPERTY ViewPortTop AS LONG AUTO
PROPERTY ViewPortWidth AS LONG AUTO
PROPERTY VScrollSmallChange AS LONG AUTO
PROPERTY WhatsThisButton AS USUAL AUTO
PROPERTY WhatsThisHelp AS LOGIC AUTO

METHOD WhatsThisMode AS USUAL CLIPPER
RETURN NIL
//PROPERTY WINDOWSTATE AS USUAL AUTO
//PROPERTY WINDOWTYPE AS USUAL AUTO
PROPERTY ZoomBox AS LOGIC AUTO
END CLASS
END NAMESPACE      
