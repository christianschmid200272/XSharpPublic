﻿
//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//

USING XSharpModel
USING System.Diagnostics
USING System.Collections.Generic
using LanguageService.CodeAnalysis.XSharp.SyntaxParser
USING System.Runtime.InteropServices

// imported from XSharpLexer.tokens
// Keep in Sync !
BEGIN NAMESPACE XSharpModel
    ENUM XTokenType AS SHORT
        MEMBER None := 0
        MEMBER @@First_keyword:= XSharpLexer.FIRST_KEYWORD
        MEMBER @@Access:= XSharpLexer.ACCESS
        MEMBER @@Align:= XSharpLexer.ALIGN
        MEMBER @@As:= XSharpLexer.AS
        MEMBER @@Aspen:= XSharpLexer.ASPEN
        MEMBER @@Assign:= XSharpLexer.ASSIGN
        MEMBER @@Begin:= XSharpLexer.BEGIN
        MEMBER @@Break:= XSharpLexer.BREAK
        MEMBER @@Callback:= XSharpLexer.CALLBACK
        MEMBER @@Case:= XSharpLexer.CASE
        MEMBER @@Cast:= XSharpLexer.CAST
        MEMBER @@Class:= XSharpLexer.CLASS
        MEMBER @@Clipper:= XSharpLexer.CLIPPER
        MEMBER @@Declare:= XSharpLexer.DECLARE
        MEMBER @@Define:= XSharpLexer.DEFINE
        MEMBER @@Dim:= XSharpLexer.DIM
        MEMBER @@Dll:= XSharpLexer.DLL
        MEMBER @@Dllexport:= XSharpLexer.DLLEXPORT
        MEMBER @@Do:= XSharpLexer.DO
        MEMBER @@Downto:= XSharpLexer.DOWNTO
        MEMBER @@Else:= XSharpLexer.ELSE
        MEMBER @@Elseif:= XSharpLexer.ELSEIF
        MEMBER @@End:= XSharpLexer.END
        MEMBER @@Endcase:= XSharpLexer.ENDCASE
        MEMBER @@Enddo:= XSharpLexer.ENDDO
        MEMBER @@Endif:= XSharpLexer.ENDIF
        MEMBER @@Exit:= XSharpLexer.EXIT
        MEMBER @@Export:= XSharpLexer.EXPORT
        MEMBER @@Fastcall:= XSharpLexer.FASTCALL
        MEMBER @@Field:= XSharpLexer.FIELD
        MEMBER @@For:= XSharpLexer.FOR
        MEMBER @@Function:= XSharpLexer.FUNCTION
        MEMBER @@Global:= XSharpLexer.GLOBAL
        MEMBER @@Hidden:= XSharpLexer.HIDDEN
        MEMBER @@If:= XSharpLexer.IF
        MEMBER @@Iif:= XSharpLexer.IIF
        MEMBER @@Inherit:= XSharpLexer.INHERIT
        MEMBER @@Init1:= XSharpLexer.INIT1
        MEMBER @@Init2:= XSharpLexer.INIT2
        MEMBER @@Init3:= XSharpLexer.INIT3
        MEMBER @@Instance:= XSharpLexer.INSTANCE
        MEMBER @@Is:= XSharpLexer.IS
        MEMBER @@In:= XSharpLexer.IN
        MEMBER @@Local:= XSharpLexer.LOCAL
        MEMBER @@Loop:= XSharpLexer.LOOP
        MEMBER @@Member:= XSharpLexer.MEMBER
        MEMBER @@Memvar:= XSharpLexer.MEMVAR
        MEMBER @@Method:= XSharpLexer.METHOD
        MEMBER @@Nameof:= XSharpLexer.NAMEOF
        MEMBER @@Next:= XSharpLexer.NEXT
        MEMBER @@Otherwise:= XSharpLexer.OTHERWISE
        MEMBER @@Parameters:= XSharpLexer.PARAMETERS
        MEMBER @@Pascal:= XSharpLexer.PASCAL
        MEMBER @@Private:= XSharpLexer.PRIVATE
        MEMBER @@Procedure:= XSharpLexer.PROCEDURE
        MEMBER @@Protected:= XSharpLexer.PROTECTED
        MEMBER @@Public:= XSharpLexer.PUBLIC
        MEMBER @@Recover:= XSharpLexer.RECOVER
        MEMBER @@Return:= XSharpLexer.RETURN
        MEMBER @@Self:= XSharpLexer.SELF
        MEMBER @@Sequence:= XSharpLexer.SEQUENCE
        MEMBER @@Sizeof:= XSharpLexer.SIZEOF
        MEMBER @@Static:= XSharpLexer.STATIC
        MEMBER @@Step:= XSharpLexer.STEP
        MEMBER @@Strict:= XSharpLexer.STRICT
        MEMBER @@Super:= XSharpLexer.SUPER
        MEMBER @@Thiscall:= XSharpLexer.THISCALL
        MEMBER @@To:= XSharpLexer.TO
        MEMBER @@Typeof:= XSharpLexer.TYPEOF
        MEMBER @@Union:= XSharpLexer.UNION
        MEMBER @@Upto:= XSharpLexer.UPTO
        MEMBER @@Using:= XSharpLexer.USING
        MEMBER @@While:= XSharpLexer.WHILE
        MEMBER @@Wincall:= XSharpLexer.WINCALL
        MEMBER @@Catch:= XSharpLexer.CATCH
        MEMBER @@Finally:= XSharpLexer.FINALLY
        MEMBER @@Throw:= XSharpLexer.THROW
        MEMBER @@First_positional_keyword:= XSharpLexer.FIRST_POSITIONAL_KEYWORD
        MEMBER @@Abstract:= XSharpLexer.ABSTRACT
        MEMBER @@Auto:= XSharpLexer.AUTO
        MEMBER @@Castclass:= XSharpLexer.CASTCLASS
        MEMBER @@Constructor:= XSharpLexer.CONSTRUCTOR
        MEMBER @@Const:= XSharpLexer.CONST
        MEMBER @@Default:= XSharpLexer.DEFAULT
        MEMBER @@Delegate:= XSharpLexer.DELEGATE
        MEMBER @@Destructor:= XSharpLexer.DESTRUCTOR
        MEMBER @@Enum:= XSharpLexer.ENUM
        MEMBER @@Event:= XSharpLexer.EVENT
        MEMBER @@Explicit:= XSharpLexer.EXPLICIT
        MEMBER @@Foreach:= XSharpLexer.FOREACH
        MEMBER @@Get:= XSharpLexer.GET
        MEMBER @@Implements:= XSharpLexer.IMPLEMENTS
        MEMBER @@Implicit:= XSharpLexer.IMPLICIT
        MEMBER @@Implied:= XSharpLexer.IMPLIED
        MEMBER @@Initonly:= XSharpLexer.INITONLY
        MEMBER @@Interface:= XSharpLexer.INTERFACE
        MEMBER @@Internal:= XSharpLexer.INTERNAL
        MEMBER @@Lock:= XSharpLexer.LOCK
        MEMBER @@Namespace:= XSharpLexer.NAMESPACE
        MEMBER @@New:= XSharpLexer.NEW
        MEMBER @@Operator:= XSharpLexer.OPERATOR
        MEMBER @@Out:= XSharpLexer.OUT
        MEMBER @@Partial:= XSharpLexer.PARTIAL
        MEMBER @@Property:= XSharpLexer.PROPERTY
        MEMBER @@Repeat:= XSharpLexer.REPEAT
        MEMBER @@Scope:= XSharpLexer.SCOPE
        MEMBER @@Sealed:= XSharpLexer.SEALED
        MEMBER @@Set:= XSharpLexer.SET
        MEMBER @@Structure:= XSharpLexer.STRUCTURE
        MEMBER @@Try:= XSharpLexer.TRY
        MEMBER @@Until:= XSharpLexer.UNTIL
        MEMBER @@Value:= XSharpLexer.VALUE
        MEMBER @@Virtual:= XSharpLexer.VIRTUAL
        MEMBER @@Vostruct:= XSharpLexer.VOSTRUCT
        MEMBER @@Add:= XSharpLexer.ADD
        MEMBER @@Arglist:= XSharpLexer.ARGLIST
        MEMBER @@Ascending:= XSharpLexer.ASCENDING
        MEMBER @@Async:= XSharpLexer.ASYNC
        MEMBER @@Astype:= XSharpLexer.ASTYPE
        MEMBER @@Await:= XSharpLexer.AWAIT
        MEMBER @@By:= XSharpLexer.BY
        MEMBER @@Checked:= XSharpLexer.CHECKED
        MEMBER @@Descending:= XSharpLexer.DESCENDING
        MEMBER @@Equals:= XSharpLexer.EQUALS
        MEMBER @@Extern:= XSharpLexer.EXTERN
        MEMBER @@Fixed:= XSharpLexer.FIXED
        MEMBER @@From:= XSharpLexer.FROM
        MEMBER @@Group:= XSharpLexer.GROUP
        MEMBER @@Init:= XSharpLexer.INIT
        MEMBER @@Into:= XSharpLexer.INTO
        MEMBER @@Join:= XSharpLexer.JOIN
        MEMBER @@Let:= XSharpLexer.LET
        MEMBER @@Nop:= XSharpLexer.NOP
        MEMBER @@Of:= XSharpLexer.OF
        MEMBER @@On:= XSharpLexer.ON
        MEMBER @@Orderby:= XSharpLexer.ORDERBY
        MEMBER @@Override:= XSharpLexer.OVERRIDE
        MEMBER @@Params:= XSharpLexer.PARAMS
        MEMBER @@Remove:= XSharpLexer.REMOVE
        MEMBER @@Select:= XSharpLexer.SELECT
        MEMBER @@Switch:= XSharpLexer.SWITCH
        MEMBER @@Unchecked:= XSharpLexer.UNCHECKED
        MEMBER @@Unsafe:= XSharpLexer.UNSAFE
        MEMBER @@Var:= XSharpLexer.VAR
        MEMBER @@Volatile:= XSharpLexer.VOLATILE
        MEMBER @@When:= XSharpLexer.WHEN
        MEMBER @@Where:= XSharpLexer.WHERE
        MEMBER @@Yield:= XSharpLexer.YIELD
        MEMBER @@With:= XSharpLexer.WITH
        MEMBER @@Last_positional_keyword:= XSharpLexer.LAST_POSITIONAL_KEYWORD
        MEMBER @@First_type:= XSharpLexer.FIRST_TYPE
        MEMBER @@Array:= XSharpLexer.ARRAY
        MEMBER @@Byte:= XSharpLexer.BYTE
        MEMBER @@Codeblock:= XSharpLexer.CODEBLOCK
        MEMBER @@Date:= XSharpLexer.DATE
        MEMBER @@Dword:= XSharpLexer.DWORD
        MEMBER @@Float:= XSharpLexer.FLOAT
        MEMBER @@Int:= XSharpLexer.INT
        MEMBER @@Logic:= XSharpLexer.LOGIC
        MEMBER @@Longint:= XSharpLexer.LONGINT
        MEMBER @@Object:= XSharpLexer.OBJECT
        MEMBER @@Psz:= XSharpLexer.PSZ
        MEMBER @@Ptr:= XSharpLexer.PTR
        MEMBER @@Real4:= XSharpLexer.REAL4
        MEMBER @@Real8:= XSharpLexer.REAL8
        MEMBER @@Ref:= XSharpLexer.REF
        MEMBER @@Shortint:= XSharpLexer.SHORTINT
        MEMBER @@String:= XSharpLexer.STRING
        MEMBER @@Symbol:= XSharpLexer.SYMBOL
        MEMBER @@Usual:= XSharpLexer.USUAL
        MEMBER @@Void:= XSharpLexer.VOID
        MEMBER @@Word:= XSharpLexer.WORD
        MEMBER @@Char:= XSharpLexer.CHAR
        MEMBER @@Int64:= XSharpLexer.INT64
        MEMBER @@Uint64:= XSharpLexer.UINT64
        MEMBER @@Dynamic:= XSharpLexer.DYNAMIC
        MEMBER @@Decimal:= XSharpLexer.DECIMAL
        MEMBER @@Datetime:= XSharpLexer.DATETIME
        MEMBER @@Currency:= XSharpLexer.CURRENCY
        MEMBER @@Binary:= XSharpLexer.BINARY
        MEMBER @@Nint:= XSharpLexer.NINT
        MEMBER @@Nuint:= XSharpLexer.NUINT
        MEMBER @@Last_type:= XSharpLexer.LAST_TYPE
        MEMBER @@Udc_keyword:= XSharpLexer.UDC_KEYWORD
        MEMBER @@Script_ref:= XSharpLexer.SCRIPT_REF
        MEMBER @@Script_load:= XSharpLexer.SCRIPT_LOAD
        MEMBER @@Assignment:= XSharpLexer.ASSIGNMENT
        MEMBER @@Deferred:= XSharpLexer.DEFERRED
        MEMBER @@Endclass:= XSharpLexer.ENDCLASS
        MEMBER @@Exported:= XSharpLexer.EXPORTED
        MEMBER @@Freeze:= XSharpLexer.FREEZE
        MEMBER @@Final:= XSharpLexer.FINAL
        MEMBER @@Inline:= XSharpLexer.INLINE
        MEMBER @@Introduce:= XSharpLexer.INTRODUCE
        MEMBER @@Nosave:= XSharpLexer.NOSAVE
        MEMBER @@Readonly:= XSharpLexer.READONLY
        MEMBER @@Sharing:= XSharpLexer.SHARING
        MEMBER @@Shared:= XSharpLexer.SHARED
        MEMBER @@Sync:= XSharpLexer.SYNC
        MEMBER @@Enddefine:= XSharpLexer.ENDDEFINE
        MEMBER @@Lparameters:= XSharpLexer.LPARAMETERS
        MEMBER @@Olepublic:= XSharpLexer.OLEPUBLIC
        MEMBER @@Exclude:= XSharpLexer.EXCLUDE
        MEMBER @@Thisaccess:= XSharpLexer.THISACCESS
        MEMBER @@Helpstring:= XSharpLexer.HELPSTRING
        MEMBER @@Dimension:= XSharpLexer.DIMENSION
        MEMBER @@Noinit:= XSharpLexer.NOINIT
        MEMBER @@Each:= XSharpLexer.EACH
        MEMBER @@Then:= XSharpLexer.THEN
        MEMBER @@Fox_m:= XSharpLexer.FOX_M
        MEMBER @@Last_keyword:= XSharpLexer.LAST_KEYWORD
        MEMBER @@First_null:= XSharpLexer.FIRST_NULL
        MEMBER @@Nil:= XSharpLexer.NIL
        MEMBER @@Null:= XSharpLexer.NULL
        MEMBER @@Null_array:= XSharpLexer.NULL_ARRAY
        MEMBER @@Null_codeblock:= XSharpLexer.NULL_CODEBLOCK
        MEMBER @@Null_date:= XSharpLexer.NULL_DATE
        MEMBER @@Null_object:= XSharpLexer.NULL_OBJECT
        MEMBER @@Null_psz:= XSharpLexer.NULL_PSZ
        MEMBER @@Null_ptr:= XSharpLexer.NULL_PTR
        MEMBER @@Null_string:= XSharpLexer.NULL_STRING
        MEMBER @@Null_symbol:= XSharpLexer.NULL_SYMBOL
        MEMBER @@Null_fox:= XSharpLexer.NULL_FOX
        MEMBER @@Last_null:= XSharpLexer.LAST_NULL
        MEMBER @@First_operator:= XSharpLexer.FIRST_OPERATOR
        MEMBER @@Lt:= XSharpLexer.LT
        MEMBER @@Lte:= XSharpLexer.LTE
        MEMBER @@Gt:= XSharpLexer.GT
        MEMBER @@Gte:= XSharpLexer.GTE
        MEMBER @@Eq:= XSharpLexer.EQ
        MEMBER @@Eeq:= XSharpLexer.EEQ
        MEMBER @@Substr:= XSharpLexer.SUBSTR
        MEMBER @@Neq:= XSharpLexer.NEQ
        MEMBER @@Neq2:= XSharpLexer.NEQ2
        MEMBER @@Inc:= XSharpLexer.INC
        MEMBER @@Dec:= XSharpLexer.DEC
        MEMBER @@Plus:= XSharpLexer.PLUS
        MEMBER @@Minus:= XSharpLexer.MINUS
        MEMBER @@Div:= XSharpLexer.DIV
        MEMBER @@Mod:= XSharpLexer.MOD
        MEMBER @@Exp:= XSharpLexer.EXP
        MEMBER @@Lshift:= XSharpLexer.LSHIFT
        MEMBER @@Rshift:= XSharpLexer.RSHIFT
        MEMBER @@Tilde:= XSharpLexer.TILDE
        MEMBER @@Mult:= XSharpLexer.MULT
        MEMBER @@Qqmark:= XSharpLexer.QQMARK
        MEMBER @@Qmark:= XSharpLexer.QMARK
        MEMBER @@And:= XSharpLexer.AND
        MEMBER @@Or:= XSharpLexer.OR
        MEMBER @@Not:= XSharpLexer.NOT
        MEMBER @@Vo_not:= XSharpLexer.VO_NOT
        MEMBER @@Vo_and:= XSharpLexer.VO_AND
        MEMBER @@Vo_or:= XSharpLexer.VO_OR
        MEMBER @@Vo_xor:= XSharpLexer.VO_XOR
        MEMBER @@Assign_op:= XSharpLexer.ASSIGN_OP
        MEMBER @@Assign_add:= XSharpLexer.ASSIGN_ADD
        MEMBER @@Assign_sub:= XSharpLexer.ASSIGN_SUB
        MEMBER @@Assign_exp:= XSharpLexer.ASSIGN_EXP
        MEMBER @@Assign_mul:= XSharpLexer.ASSIGN_MUL
        MEMBER @@Assign_div:= XSharpLexer.ASSIGN_DIV
        MEMBER @@Assign_mod:= XSharpLexer.ASSIGN_MOD
        MEMBER @@Assign_bitand:= XSharpLexer.ASSIGN_BITAND
        MEMBER @@Assign_bitor:= XSharpLexer.ASSIGN_BITOR
        MEMBER @@Assign_lshift:= XSharpLexer.ASSIGN_LSHIFT
        MEMBER @@Assign_rshift:= XSharpLexer.ASSIGN_RSHIFT
        MEMBER @@Assign_xor:= XSharpLexer.ASSIGN_XOR
        MEMBER @@Assign_qqmark:= XSharpLexer.ASSIGN_QQMARK
        MEMBER @@Logic_and:= XSharpLexer.LOGIC_AND
        MEMBER @@Logic_or:= XSharpLexer.LOGIC_OR
        MEMBER @@Logic_not:= XSharpLexer.LOGIC_NOT
        MEMBER @@Logic_xor:= XSharpLexer.LOGIC_XOR
        MEMBER @@Fox_and:= XSharpLexer.FOX_AND
        MEMBER @@Fox_or:= XSharpLexer.FOX_OR
        MEMBER @@Fox_not:= XSharpLexer.FOX_NOT
        MEMBER @@Fox_xor:= XSharpLexer.FOX_XOR
        MEMBER @@Lparen:= XSharpLexer.LPAREN
        MEMBER @@Rparen:= XSharpLexer.RPAREN
        MEMBER @@Lcurly:= XSharpLexer.LCURLY
        MEMBER @@Rcurly:= XSharpLexer.RCURLY
        MEMBER @@Lbrkt:= XSharpLexer.LBRKT
        MEMBER @@Rbrkt:= XSharpLexer.RBRKT
        MEMBER @@Colon:= XSharpLexer.COLON
        MEMBER @@Comma:= XSharpLexer.COMMA
        MEMBER @@Pipe:= XSharpLexer.PIPE
        MEMBER @@Amp:= XSharpLexer.AMP
        MEMBER @@Addrof:= XSharpLexer.ADDROF
        MEMBER @@Alias:= XSharpLexer.ALIAS
        MEMBER @@Dot:= XSharpLexer.DOT
        MEMBER @@Coloncolon:= XSharpLexer.COLONCOLON
        MEMBER @@Backslash:= XSharpLexer.BACKSLASH
        MEMBER @@Ellipsis:= XSharpLexer.ELLIPSIS
        MEMBER @@Backbackslash:= XSharpLexer.BACKBACKSLASH
        MEMBER @@Last_operator:= XSharpLexer.LAST_OPERATOR
        MEMBER @@First_constant:= XSharpLexer.FIRST_CONSTANT
        MEMBER @@False_const:= XSharpLexer.FALSE_CONST
        MEMBER @@True_const:= XSharpLexer.TRUE_CONST
        MEMBER @@Hex_const:= XSharpLexer.HEX_CONST
        MEMBER @@Bin_const:= XSharpLexer.BIN_CONST
        MEMBER @@Int_const:= XSharpLexer.INT_CONST
        MEMBER @@Date_const:= XSharpLexer.DATE_CONST
        MEMBER @@Datetime_const:= XSharpLexer.DATETIME_CONST
        MEMBER @@Real_const:= XSharpLexer.REAL_CONST
        MEMBER @@Invalid_number:= XSharpLexer.INVALID_NUMBER
        MEMBER @@Symbol_const:= XSharpLexer.SYMBOL_CONST
        MEMBER @@Char_const:= XSharpLexer.CHAR_CONST
        MEMBER @@String_const:= XSharpLexer.STRING_CONST
        MEMBER @@Escaped_string_const:= XSharpLexer.ESCAPED_STRING_CONST
        MEMBER @@Interpolated_string_const:= XSharpLexer.INTERPOLATED_STRING_CONST
        MEMBER @@Incomplete_string_const:= XSharpLexer.INCOMPLETE_STRING_CONST
        MEMBER @@Text_string_const:= XSharpLexer.TEXT_STRING_CONST
        MEMBER @@Bracketed_string_const:= XSharpLexer.BRACKETED_STRING_CONST
        MEMBER @@Binary_const:= XSharpLexer.BINARY_CONST
        MEMBER @@Last_constant:= XSharpLexer.LAST_CONSTANT
        MEMBER @@PP_first:= XSharpLexer.PP_FIRST
        MEMBER @@PP_command:= XSharpLexer.PP_COMMAND
        MEMBER @@PP_define:= XSharpLexer.PP_DEFINE
        MEMBER @@PP_else:= XSharpLexer.PP_ELSE
        MEMBER @@PP_endif:= XSharpLexer.PP_ENDIF
        MEMBER @@PP_endregion:= XSharpLexer.PP_ENDREGION
        MEMBER @@PP_error:= XSharpLexer.PP_ERROR
        MEMBER @@PP_if:= XSharpLexer.PP_IF
        MEMBER @@PP_ifdef:= XSharpLexer.PP_IFDEF
        MEMBER @@PP_ifndef:= XSharpLexer.PP_IFNDEF
        MEMBER @@PP_include:= XSharpLexer.PP_INCLUDE
        MEMBER @@PP_line:= XSharpLexer.PP_LINE
        MEMBER @@PP_region:= XSharpLexer.PP_REGION
        MEMBER @@PP_stdout:= XSharpLexer.PP_STDOUT
        MEMBER @@PP_translate:= XSharpLexer.PP_TRANSLATE
        MEMBER @@PP_undef:= XSharpLexer.PP_UNDEF
        MEMBER @@PP_warning:= XSharpLexer.PP_WARNING
        MEMBER @@PP_text:= XSharpLexer.PP_TEXT
        MEMBER @@PP_endtext:= XSharpLexer.PP_ENDTEXT
        MEMBER @@PP_last:= XSharpLexer.PP_LAST
        MEMBER @@Macro:= XSharpLexer.MACRO
        MEMBER @@Udcsep:= XSharpLexer.UDCSEP
        MEMBER @@Id:= XSharpLexer.ID
        MEMBER @@Kwid:= XSharpLexer.KWID
        MEMBER @@Pragma:= XSharpLexer.PRAGMA
        MEMBER @@Doc_comment:= XSharpLexer.DOC_COMMENT
        MEMBER @@Sl_comment:= XSharpLexer.SL_COMMENT
        MEMBER @@Ml_comment:= XSharpLexer.ML_COMMENT
        MEMBER @@Line_cont:= XSharpLexer.LINE_CONT
        MEMBER @@Line_cont_old:= XSharpLexer.LINE_CONT_OLD
        MEMBER @@Semi:= XSharpLexer.SEMI
        MEMBER @@Ws:= XSharpLexer.WS
        MEMBER @@Nl:= XSharpLexer.NL
        MEMBER @@Eos:= XSharpLexer.EOS
        MEMBER @@Unrecognized:= XSharpLexer.UNRECOGNIZED
        MEMBER @@Last:= XSharpLexer.LAST
    END ENUM


    /// <summary>
    /// This structure with the size of an Int is used to store
    /// single token or double token keywords that are using
    /// for the formatting code
    /// </summary>
    [StructLayout(LayoutKind.Explicit, Size := 4)];
    STRUCTURE XKeyword IMPLEMENTS IEquatable<XKeyword>, IEqualityComparer<XKeyword>
        [FieldOffset(0)];
        PUBLIC INITONLY Kw1 as XTokenType
        [FieldOffset(2)];
        PUBLIC INITONLY Kw2 as XTokenType
        [FieldOffset(0)];
        PRIVATE INITONLY _code as int
        PROPERTY IsEmpty  as LOGIC => _code == 0
        PROPERTY IsBegin  as LOGIC => Kw1 == XTokenType.Begin
        PROPERTY IsEnd    as LOGIC => Kw1 == XTokenType.End
        PROPERTY IsSingle as LOGIC => Kw2 == XTokenType.None

        CONSTRUCTOR(kw1 as LONG, kw2 as LONG)
            SELF( (XTokenType) kw1, (XTokenType) kw2)

        CONSTRUCTOR(kw1 as XTokenType, kw2 as XTokenType)
            _code := 0
            SELF:Kw1 := kw1
            if kw2 == XTokenType.Var
                SELF:Kw2 := XTokenType.None
            else
                SELF:Kw2 := kw2
            endif

        CONSTRUCTOR(kw1 as LONG)
            SELF((XTokenType) kw1, XTokenType.None)
            
        CONSTRUCTOR(kw1 as XTokenType)
            SELF(kw1, XTokenType.None)
            
        OVERRIDE METHOD ToString() AS STRING
            IF Kw2 == XTokenType.None
                RETURN Kw1:ToString()
            ENDIF
            RETURN Kw1:ToString()+"_"+Kw2:ToString()
         METHOD Equals(x as XKeyword , y as XKeyword ) AS LOGIC
             RETURN x:Equals(y)

         METHOD Equals(other as XKeyword ) AS LOGIC
             RETURN _code == other._code

         METHOD GetHashCode(obj as XKeyword ) AS INT
              RETURN obj:_code

    END STRUCTURE


END NAMESPACE


