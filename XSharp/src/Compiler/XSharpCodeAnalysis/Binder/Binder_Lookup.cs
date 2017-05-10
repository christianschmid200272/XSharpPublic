﻿// Copyright (c) Microsoft.  All Rights Reserved.  Licensed under the Apache License, Version 2.0.  See License.txt in the project root for license information.

using System.Collections.Generic;
using System.Collections.Immutable;
using System.Diagnostics;
using System.Linq;
using Microsoft.CodeAnalysis.Collections;
using Microsoft.CodeAnalysis.CSharp.Symbols;
using Roslyn.Utilities;

namespace Microsoft.CodeAnalysis.CSharp
{
    internal partial class Binder
    {
        /// <summary>
        /// Look for any symbols in scope with the given name and arity.
        /// </summary>
        /// <remarks>
        /// Makes a second attempt if the results are not viable, in order to produce more detailed failure information (symbols and diagnostics).
        /// </remarks>
        private Binder XSLookupSymbolsWithFallback(LookupResult result, string name, int arity, ref HashSet<DiagnosticInfo> useSiteDiagnostics, ConsList<Symbol> basesBeingResolved = null, LookupOptions options = LookupOptions.Default)
        {
            Debug.Assert(options.AreValid());

            // don't create diagnosis instances unless lookup fails
            var binder = this.LookupSymbolsInternal(result, name, arity, basesBeingResolved, options, diagnose: false, useSiteDiagnostics: ref useSiteDiagnostics);
            FilterResults(result, options);
            if (result.Kind != LookupResultKind.Viable && result.Kind != LookupResultKind.Empty)
            {
                result.Clear();
                // retry to get diagnosis
                var otherBinder = this.LookupSymbolsInternal(result, name, arity, basesBeingResolved, options, diagnose: true, useSiteDiagnostics: ref useSiteDiagnostics);
                Debug.Assert(binder == otherBinder);
            }

            Debug.Assert(result.IsMultiViable || result.IsClear || result.Error != null);
            return binder;
        }
        private Binder XSLookupSymbolsInternal(
            LookupResult result, string name, int arity, ConsList<Symbol> basesBeingResolved, LookupOptions options, bool diagnose, ref HashSet<DiagnosticInfo> useSiteDiagnostics)
        {
            Debug.Assert(result.IsClear);
            Debug.Assert(options.AreValid());

            Binder binder = null;
            for (var scope = this; scope != null && !result.IsMultiViable; scope = scope.Next)
            {
                if (binder != null)
                {
                    var tmp = LookupResult.GetInstance();
                    scope.LookupSymbolsInSingleBinder(tmp, name, arity, basesBeingResolved, options, this, diagnose, ref useSiteDiagnostics);
                    if (options.HasFlag(LookupOptions.DefinesOnly) && !tmp.IsClear)
                    {
                        FilterResults(tmp, options);
                    }
                    result.MergeEqual(tmp);
                    tmp.Free();
                }
                else
                {
                    scope.LookupSymbolsInSingleBinder(result, name, arity, basesBeingResolved, options, this, diagnose, ref useSiteDiagnostics);
                    if (options.HasFlag(LookupOptions.DefinesOnly) && !result.IsClear)
                    {
                        FilterResults(result, options);
                    }
                    if (!result.IsClear)
                    {
                        binder = scope;
                    }
                }
            }
            return binder;
        }

    }
}