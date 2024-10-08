﻿// Spinner.prg
//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.


USING System
USING System.Collections.Generic
USING System.Text
USING System.Windows.Forms
USING System.Drawing
USING System.ComponentModel

BEGIN NAMESPACE  XSharp.VFP.UI

	/// <summary>
    /// The VFP compatible Spinner class.
    /// </summary>
	PARTIAL CLASS Spinner INHERIT System.Windows.Forms.NumericUpDown
		// Common properties that all VFP Objects support
		#include "Headers\VFPObject.xh"

		#include "XSharp\VFPProperties.xh"

		#include "Headers\FontProperties.xh"


    CONSTRUCTOR()
			SUPER()
			SELF:SetStyle( ControlStyles.SupportsTransparentBackColor, true)
            SELF:BackColor := Color.Transparent
            SELF:Size := Size{100,24}

#include "Headers\ControlProperties.xh"

#include "Headers\ControlSource.xh"

		//Todo: See how we can map this to the NumericUpdown
		//PROPERTY SelLength AS LONG GET SELF:SelectionLength SET SELF:SelectionLength := Value
		//PROPERTY SelStart AS LONG GET SELF:SelectionStart SET SELF:SelectionStart := Value
		//PROPERTY SelText AS STRING GET SELF:SelectedText  SET SelectedText  := Value

		PROPERTY SpinnerHighValue AS LONG GET (LONG) SUPER:Maximum SET SUPER:Maximum := Value
		PROPERTY SpinnerLowValue AS LONG GET (LONG) SUPER:Minimum SET SUPER:Minimum := Value

		PROPERTY KeyboardHighValue AS LONG GET (LONG) SUPER:Maximum SET SUPER:Maximum := Value
		PROPERTY KeyboardLowValue AS LONG GET (LONG) SUPER:Minimum SET SUPER:Minimum := Value


	END CLASS
END NAMESPACE // xsVFPLibrary
