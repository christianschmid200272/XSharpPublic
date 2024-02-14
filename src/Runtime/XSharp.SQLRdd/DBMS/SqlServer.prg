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
using XSharp.RDD.Enums
using XSharp.RDD.Support
begin namespace XSharp.RDD.SqlRDD.Providers

/// <summary>
/// The SqlServer provider class.
/// </summary>
/// <remarks>
/// This class depends on the DLL System.Data.dll
/// </remarks>

class SqlServer inherit SqlDbProvider
    /// <inheritdoc />
    override property DllName as string => "System.Data.dll"
    /// <inheritdoc />
    override property TypeName as string => "System.Data.SqlClient.SqlClientFactory"
    /// <inheritdoc />
    override property GetIdentity            as string => "select @@IDENTITY"
    /// <inheritdoc />
    override property GetRowCount            as string => "select @@ROWCOUNT"

    constructor() strict
        super("SqlServer")
        return
    end constructor

    private static aFuncs := null as Dictionary<string, string>
    /// <inheritdoc />
    override method GetFunctions() as Dictionary<string, string>
        if aFuncs == null
            aFuncs := Dictionary<string, string>{StringComparer.OrdinalIgnoreCase} {;
                {"STR(%1%,%2%,%3%)"			,"STR(%1%,%2%,%3%)"},;
                {"STR(%1%,%2%)"				,"STR(%1%,%2%,0)"},;
                {"SUBSTR(%1%,%2%,%3%)"		,"SUBSTRING(%1%,%2%,%3%)"},;
                {"DTOS(%1%)"				,"CONVERT(char(8), %1%,11)"},;
                {"IIF(%1%,%2%,%3%)"			,"CASE WHEN %1% THEN %2% ELSE %3% END"},;
                {"TODAY()"					,"GETDATE()"},;
                {"CHR(%1%)"					,"CHAR(%1%)"},;
                {"REPL(%1%,%2%)"			,"REPLICATE(%1%,%2%)"},;
                {"ASC(%1%)"					,"ASCII(%1%)"},;
                {"TRIM(%1%)"				,"RTRIM(%1%)"},;
                {"ALLTRIM(%1%)"				,"TRIM(%1%)"},;
                {"+"						,"+"}}
        endif
        return aFuncs
    end method

    /// <inheritdoc />
    override method GetSqlColumnInfo(oInfo as RddFieldInfo) as string
        local sResult as string
        switch oInfo:FieldType
        case DbFieldType.Character
        case DbFieldType.VarChar
            sResult := i"{QuoteIdentifier(oInfo.ColumnName)} nvarchar ({oInfo.Length}) default ''"
            if oInfo:Flags:HasFlag(DBFFieldFlags.Nullable)
                sResult += " null "
            endif
       case DbFieldType.Integer
            sResult := i"{QuoteIdentifier(oInfo.ColumnName)} int "
            if oInfo:Flags:HasFlag(DBFFieldFlags.AutoIncrement)
                sResult += " identity "
            else
                sResult += "default 0"
            endif

        otherwise
            sResult := super:GetSqlColumnInfo(oInfo)
        end switch
        return sResult
    end method
end class
end namespace // XSharp.RDD.SqlRDD.SupportClasses
