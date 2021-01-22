﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//

using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Threading;
using Microsoft.CodeAnalysis.Collections;
using Microsoft.CodeAnalysis.CSharp.Symbols;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.PooledObjects;
using Roslyn.Utilities;

namespace Microsoft.CodeAnalysis.CSharp.Symbols
{
    internal partial class SourcePropertyAccessorSymbol
    {
        private TypeWithAnnotations _changedReturnType = default;
        private ImmutableArray<ParameterSymbol> _changedParameters = default;
        private bool _signatureChanged = false;
        private MethodSymbol _parentMethod;

        internal void ChangeSignature(TypeWithAnnotations returnType, ImmutableArray<ParameterSymbol> parameters)
        {
            _changedReturnType = returnType;

            var newparameters = ArrayBuilder<ParameterSymbol>.GetInstance(parameters.Length);
            foreach (var p in parameters)
            {
                var type = TypeWithAnnotations.Create(p.Type);
                newparameters.Add(new SynthesizedAccessorValueParameterSymbol(this, type, newparameters.Count));

            }
            _changedParameters = newparameters.ToImmutableAndFree();
            _signatureChanged = true;
            this.DeclarationModifiers |= DeclarationModifiers.Override;
            this.flags = new Flags(flags.MethodKind, this.DeclarationModifiers , this.ReturnsVoid,flags.IsExtensionMethod, flags.IsMetadataVirtual());

        }
        internal void SetOverriddenMethod(MethodSymbol m)
        {
            _parentMethod = m;
        }

        public override MethodSymbol OverriddenMethod
        {
            get
            {
                if (_parentMethod != null)
                    return _parentMethod;
                return base.OverriddenMethod;
            }
        }
    }
    internal sealed partial class SourcePropertySymbol
    {
        private TypeWithAnnotations _newPropertyType = default;
        private bool _typeChanged = false;



        internal PropertySymbol validateProperty(PropertySymbol overriddenProperty, DiagnosticBag diagnostics, Location location)
        {
            if (overriddenProperty == null && XSharpString.CaseSensitive)
            {
                // check if we have a base type and if the base type has a method with the same name but different casing
                var baseType = this.ContainingType.BaseTypeNoUseSiteDiagnostics;
                var members = baseType.GetMembersUnordered().Where(
                        member => member.Kind == SymbolKind.Property && member.IsVirtual && String.Equals(member.Name, this.Name, StringComparison.OrdinalIgnoreCase) );
                if (members.Count() > 0)
                {
                    foreach (var member in members)
                    {
                        var propSym = member as PropertySymbol;
                        bool equalSignature = propSym.ParameterCount == this.ParameterCount && TypeSymbol.Equals(this.Type, propSym.Type);
                        if (equalSignature)
                        {
                            var thisTypes = this.Parameters;
                            var theirTypes = propSym.Parameters;
                            for (int i = 0; i < thisTypes.Length; i++)
                            {
                                if (!TypeSymbol.Equals(thisTypes[i].Type,theirTypes[i].Type))
                                {
                                    equalSignature = false;
                                    break;
                                }
                            }
                        }
                        if (equalSignature)
                        {
                            diagnostics.Add(ErrorCode.ERR_CaseDifference, location, baseType.Name, "property", member.Name, this.Name);
                        }

                    }
                }

            }
            return this;
        }
        internal void SetChangedParentType(TypeWithAnnotations type)
        {
            _newPropertyType = type;
            _typeChanged = true;
            if (this.GetMethod != null && this.OverriddenProperty.GetMethod != null)
            {
                var m = (SourcePropertyAccessorSymbol)this.GetMethod;
                var m2 = this.OverriddenProperty.GetMethod;
                m.ChangeSignature(TypeWithAnnotations.Create(m2.ReturnType), m2.Parameters);
                m.SetOverriddenMethod(m2);
            }
            if (this.SetMethod != null && this.OverriddenProperty.SetMethod != null)
            {
                var m = (SourcePropertyAccessorSymbol)this.SetMethod;
                var m2 = this.OverriddenProperty.SetMethod;
                m.ChangeSignature(TypeWithAnnotations.Create(m2.ReturnType), m2.Parameters);
                m.SetOverriddenMethod(m2);
            }
        }
    }

}
