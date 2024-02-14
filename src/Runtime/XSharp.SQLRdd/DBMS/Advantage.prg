﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//

using System
using System.Collections.Generic
using System.Text
using XSharp.RDD.SqlRDD
using System.Data.Common
using System.Reflection
using XSharp.RDD.Enums
using XSharp.RDD.Support
begin namespace XSharp.RDD.SqlRDD.Providers

/// <summary>
/// The ODBC class.
/// </summary>
class Advantage inherit SqlDbProvider
    /// <inheritdoc />
    override property DllName as string => "Advantage.Data.Provider.Dll"
    /// <inheritdoc />
    override property TypeName as string => "Advantage.Data.Provider.AdsFactory"

    constructor()
        super("Advantage")
        return
    end constructor

    private static aFuncs := null as Dictionary<string, string>
    /// <inheritdoc />
    override method GetFunctions() as Dictionary<string, string>
        if aFuncs == null
            aFuncs := Dictionary<string, string>{StringComparer.OrdinalIgnoreCase}
        endif
        return aFuncs
    end method

end class
end namespace // XSharp.RDD.SqlRDD.SupportClasses
