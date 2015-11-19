﻿using System;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Collections.Immutable;
using System.Diagnostics;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.Text;
using Roslyn.Utilities;
using InternalSyntax = Microsoft.CodeAnalysis.CSharp.Syntax.InternalSyntax;
using Antlr4.Runtime;
using Antlr4.Runtime.Atn;
using Antlr4.Runtime.Misc;
using Antlr4.Runtime.Tree;
using LanguageService.CodeAnalysis.XSharp.SyntaxParser;

namespace Microsoft.CodeAnalysis.CSharp.Syntax.InternalSyntax
{
    internal static class TokenExtensions
    {
        private static bool IsHexDigit(char c) => (c >= '0' && c<= '9') || (c >= 'A' && c<= 'F') || (c >= 'a' && c<= 'f');

        private static char EscapedChar(string s, ref int pos)
        {
            if (s[pos] != '\\' || pos == s.Length-1)
                return s[pos++];
            else {
                switch (s[++pos]) {
                    case '\\':
                    case '\'':
                    case '"':
                        return s[pos++];
                    case '0':
                        pos++;
                        return '\0';
                    case 'A':
                    case 'a':
                        pos++;
                        return '\a';
                    case 'B':
                    case 'b':
                        pos++;
                        return '\b';
                    case 'F':
                    case 'f':
                        pos++;
                        return '\f';
                    case 'N':
                    case 'n':
                        pos++;
                        return '\n';
                    case 'R':
                    case 'r':
                        pos++;
                        return '\r';
                    case 'T':
                    case 't':
                        pos++;
                        return '\t';
                    case 'V':
                    case 'v':
                        pos++;
                        return '\v';
                    case 'X':
                    case 'x':
                        {
                            int l = 0;
                            pos++;
                            while (l < 4 && pos+l < s.Length && IsHexDigit(s[pos+l]))
                                l++;
                            if (l > 0) {
                                pos += l;
                                return (char)HexValue(s.Substring(pos-l,l));
                            }
                            else
                                return s[pos-1];
                        }
                    case 'U':
                    case 'u':
                        {
                            int l = 0;
                            pos++;
                            while (l < 8 && pos+l < s.Length && IsHexDigit(s[pos+l]))
                                l++;
                            if (l == 4 || l == 8) {
                                pos += l;
                                return (char)HexValue(s.Substring(pos-l,l));
                            }
                            else
                                return s[pos-1];
                        }
                    default:
                        return s[pos++];
                }
            }
        }

        private static char CharValue(string text)
        {
            int p = 1;
            return EscapedChar(text, ref p);
        }

        private static string StringValue(string text)
        {
            return text.Substring(1, text.Length - 2);
        }

        private static string EscapedStringValue(string text)
        {
            if (text.Length == 2)
                return "";
            StringBuilder sb = new StringBuilder();
            int p = 1;
            while (p < text.Length-1)
                sb.Append(EscapedChar(text, ref p));
            return sb.ToString();
        }

        private static long HexValue(string text)
        {
            long r = 0;
            foreach (char c in text)
            {
                char cu = char.ToUpper(c);
                if (cu != 'U' && cu != 'L')
                {
                    r <<= 4;
                    if (cu >= '0' && cu <= '9')
                        r |= (long)(cu - '0');
                    else
                        r |= (long)((cu - 'A') + 10);
                }
            }
            return r;
        }

        private static long BinValue(string text)
        {
            long r = 0;
            foreach (char c in text)
            {
                char cu = char.ToUpper(c);
                if (cu != 'U')
                {
                    r <<= 1;
                    if (cu == '1')
                        r |= 1;
                }
            }
            return r;
        }

        public static SyntaxToken SyntaxIdentifier(this IToken token)
        {
            (token as CommonToken).Type = XSharpParser.ID;
            var r = SyntaxFactory.Identifier(token.Text);
            r.XNode = new TerminalNodeImpl(token);
            return r;
        }

        public static SyntaxToken SyntaxKeywordIdentifier(this IToken token)
        {
            var r = SyntaxFactory.Identifier(token.Text);
            r.XNode = new TerminalNodeImpl(token);
            return r;
        }

        public static SyntaxToken SyntaxNativeType(this IToken token)
        {
            SyntaxToken r;
            switch (token.Type)
            {
                case XSharpParser.BYTE:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ByteKeyword);
                    break;
                //case XSharpParser.CODEBLOCK:
                //    r = SyntaxFactory.MakeToken(SyntaxKind.VoidKeyword);
                //    break;
                //case XSharpParser.DATE:
                //    r = SyntaxFactory.MakeToken(SyntaxKind.VoidKeyword);
                //    break;
                case XSharpParser.DWORD:
                    r = SyntaxFactory.MakeToken(SyntaxKind.UIntKeyword);
                    break;
                //case XSharpParser.FLOAT:
                //    r = SyntaxFactory.MakeToken(SyntaxKind.DoubleKeyword);
                //    break;
                case XSharpParser.SHORTINT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ShortKeyword);
                    break;
                case XSharpParser.INT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.IntKeyword);
                    break;
                case XSharpParser.INT64:
                    r = SyntaxFactory.MakeToken(SyntaxKind.LongKeyword);
                    break;
                case XSharpParser.LOGIC:
                    r = SyntaxFactory.MakeToken(SyntaxKind.BoolKeyword);
                    break;
                case XSharpParser.LONGINT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.IntKeyword);
                    break;
                case XSharpParser.OBJECT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ObjectKeyword);
                    break;
                //case XSharpParser.PSZ:
                //    r = SyntaxFactory.MakeToken(SyntaxKind.VoidKeyword);
                //    break;
                //case XSharpParser.PTR:
                //    r = SyntaxFactory.MakeToken(SyntaxKind.);
                //    break;
                case XSharpParser.REAL4:
                    r = SyntaxFactory.MakeToken(SyntaxKind.FloatKeyword);
                    break;
                case XSharpParser.REAL8:
                    r = SyntaxFactory.MakeToken(SyntaxKind.DoubleKeyword);
                    break;
                case XSharpParser.STRING:
                    r = SyntaxFactory.MakeToken(SyntaxKind.StringKeyword);
                    break;
                //case XSharpParser.SYMBOL:
                //    r = SyntaxFactory.MakeToken(SyntaxKind.StringKeyword);
                //    break;
                //case XSharpParser.USUAL:
                //    r = SyntaxFactory.MakeToken(SyntaxKind.VoidKeyword);
                //    break;
                case XSharpParser.UINT64:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ULongKeyword);
                    break;
                case XSharpParser.WORD:
                    r = SyntaxFactory.MakeToken(SyntaxKind.UShortKeyword);
                    break;
                case XSharpParser.VOID:
                    r = SyntaxFactory.MakeToken(SyntaxKind.VoidKeyword);
                    break;
                case XSharpParser.CHAR:
                    r = SyntaxFactory.MakeToken(SyntaxKind.CharKeyword);
                    break;
                //case XSharpParser.ARRAY:
                //    r = SyntaxFactory.MakeToken(SyntaxKind.);
                //    break;
                default:
                    r = SyntaxFactory.MakeToken(SyntaxKind.BadToken).WithAdditionalDiagnostics(
                        new SyntaxDiagnosticInfo(0, token.Text.Length, ErrorCode.ERR_SyntaxError, token));
                    break;
            }
            r.XNode = new TerminalNodeImpl(token);
            return r;
        }

        public static SyntaxToken SyntaxLiteralValue(this IToken token)
        {
            SyntaxToken r;
            switch (token.Type)
            {
                case XSharpParser.TRUE_CONST:
                    r = SyntaxFactory.MakeToken(SyntaxKind.TrueKeyword);
                    break;
                case XSharpParser.FALSE_CONST:
                    r = SyntaxFactory.MakeToken(SyntaxKind.FalseKeyword);
                    break;
                case XSharpParser.CHAR_CONST:
                    r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, CharValue(token.Text), SyntaxFactory.WS);
                    break;
                case XSharpParser.STRING_CONST:
                    r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, StringValue(token.Text), SyntaxFactory.WS);
                    break;
                case XSharpParser.ESCAPED_STRING_CONST:
                    r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, EscapedStringValue(token.Text), SyntaxFactory.WS);
                    break;
                case XSharpParser.SYMBOL_CONST:
                    r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, token.Text.Substring(1).ToUpper(), SyntaxFactory.WS)
                        .WithAdditionalDiagnostics(new SyntaxDiagnosticInfo(0, token.Text.Length, ErrorCode.ERR_FeatureNotAvailableInVersion1, token));
                    break;
                case XSharpParser.HEX_CONST:
                    switch (token.Text.Last()) {
                        case 'U':
                        case 'u':
                            if (token.Text.Length > 32+3)
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, (ulong)HexValue(token.Text.Substring(2)), SyntaxFactory.WS);
                            else
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, (uint)HexValue(token.Text.Substring(2)), SyntaxFactory.WS);
                            break;
                        case 'L':
                        case 'l':
                            if (token.Text.Length > 32+3)
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, HexValue(token.Text.Substring(2)), SyntaxFactory.WS);
                            else
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, (int)HexValue(token.Text.Substring(2)), SyntaxFactory.WS);
                            break;
                        default:
                            if (token.Text.Length > 32+2)
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, HexValue(token.Text.Substring(2)), SyntaxFactory.WS);
                            else
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, (int)HexValue(token.Text.Substring(2)), SyntaxFactory.WS);
                            break;
                    }
                    break;
                case XSharpParser.BIN_CONST:
                    switch (token.Text.Last()) {
                        case 'U':
                        case 'u':
                            if (token.Text.Length > 32+3)
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, (ulong)BinValue(token.Text.Substring(2)), SyntaxFactory.WS);
                            else
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, (uint)BinValue(token.Text.Substring(2)), SyntaxFactory.WS);
                            break;
                        case 'L':
                        case 'l':
                            if (token.Text.Length > 32+3)
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, BinValue(token.Text.Substring(2)), SyntaxFactory.WS);
                            else
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, (int)BinValue(token.Text.Substring(2)), SyntaxFactory.WS);
                            break;
                        default:
                            if (token.Text.Length > 32+2)
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, BinValue(token.Text.Substring(2)), SyntaxFactory.WS);
                            else
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, (int)BinValue(token.Text.Substring(2)), SyntaxFactory.WS);
                            break;
                    }
                    break;
                case XSharpParser.REAL_CONST:
                    switch (token.Text.Last()) {
                        case 'M':
                        case 'm':
                            r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, decimal.Parse(token.Text.Substring(0,token.Text.Length-1)), SyntaxFactory.WS);
                            break;
                        case 'S':
                        case 's':
                            r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, float.Parse(token.Text.Substring(0,token.Text.Length-1)), SyntaxFactory.WS);
                            break;
                        case 'D':
                        case 'd':
                            r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, double.Parse(token.Text.Substring(0,token.Text.Length-1)), SyntaxFactory.WS);
                            break;
                        default:
                            r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, double.Parse(token.Text), SyntaxFactory.WS);
                            break;
                    }
                    break;
                case XSharpParser.INT_CONST:
                    switch (token.Text.Last()) {
                        case 'U':
                        case 'u':
                            ulong ul = ulong.Parse(token.Text.Substring(0,token.Text.Length-1));
                            if (ul > uint.MaxValue)
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, ul, SyntaxFactory.WS);
                            else
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, (uint)ul, SyntaxFactory.WS);
                            break;
                        case 'L':
                        case 'l':
                            long l = long.Parse(token.Text.Substring(0,token.Text.Length-1));
                            if (l > int.MaxValue)
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, l, SyntaxFactory.WS);
                            else
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, (int)l, SyntaxFactory.WS);
                            break;
                        default:
                            long n = long.Parse(token.Text);
                            if (n > int.MaxValue)
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, n, SyntaxFactory.WS);
                            else
                                r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, (int)n, SyntaxFactory.WS);
                            break;
                    }
                    break;
                case XSharpParser.NULL:
                    r = SyntaxFactory.MakeToken(SyntaxKind.NullKeyword);
                    break;
                case XSharpParser.DATE_CONST:
                    r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, token.Text, SyntaxFactory.WS)
                        .WithAdditionalDiagnostics(new SyntaxDiagnosticInfo(0, token.Text.Length, ErrorCode.ERR_FeatureNotAvailableInVersion1, token));
                    break;
                case XSharpParser.NIL:
                case XSharpParser.NULL_ARRAY:
                case XSharpParser.NULL_CODEBLOCK:
                case XSharpParser.NULL_DATE:
                case XSharpParser.NULL_OBJECT:
                case XSharpParser.NULL_PSZ:
                case XSharpParser.NULL_PTR:
                case XSharpParser.NULL_STRING:
                case XSharpParser.NULL_SYMBOL:
                    r = SyntaxFactory.MakeToken(SyntaxKind.NullKeyword)
                        .WithAdditionalDiagnostics(new SyntaxDiagnosticInfo(0, token.Text.Length, ErrorCode.ERR_FeatureNotAvailableInVersion1, token));
                    break;
                default: // nvk: This catches cases where a keyword/identifier is treated as a literal string
                    r = SyntaxFactory.Literal(SyntaxFactory.WS, token.Text, token.Text, SyntaxFactory.WS);
                    break;
            }
            r.XNode = new TerminalNodeImpl(token);
            return r;
        }

        public static SyntaxToken SyntaxOp(this IToken token)
        {
            SyntaxToken r;
            switch (token.Type)
            {
                //case XSharpParser.EXP:
                //    r = SyntaxKind.None;
                //    break;
                case XSharpParser.PLUS:
                    r = SyntaxFactory.MakeToken(SyntaxKind.PlusToken);
                    break;
                case XSharpParser.MINUS:
                    r = SyntaxFactory.MakeToken(SyntaxKind.MinusToken);
                    break;
                case XSharpParser.MULT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.AsteriskToken);
                    break;
                case XSharpParser.DIV:
                    r = SyntaxFactory.MakeToken(SyntaxKind.SlashToken);
                    break;
                case XSharpParser.MOD:
                    r = SyntaxFactory.MakeToken(SyntaxKind.PercentToken);
                    break;
                case XSharpParser.LSHIFT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.LessThanLessThanToken);
                    break;
                case XSharpParser.RSHIFT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.GreaterThanGreaterThanToken);
                    break;
                case XSharpParser.LT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.LessThanToken);
                    break;
                case XSharpParser.LTE:
                    r = SyntaxFactory.MakeToken(SyntaxKind.LessThanEqualsToken);
                    break;
                case XSharpParser.GT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.GreaterThanToken);
                    break;
                case XSharpParser.GTE:
                    r = SyntaxFactory.MakeToken(SyntaxKind.GreaterThanEqualsToken);
                    break;
                case XSharpParser.EQ:
                    r = SyntaxFactory.MakeToken(SyntaxKind.EqualsEqualsToken);
                    break;
                case XSharpParser.EEQ:
                    r = SyntaxFactory.MakeToken(SyntaxKind.EqualsEqualsToken);
                    break;
                case XSharpParser.NEQ:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ExclamationEqualsToken);
                    break;
                //case XSharpParser.SUBSTR:
                //    r = SyntaxKind.None;
                //    break;
                case XSharpParser.AMP:
                    r = SyntaxFactory.MakeToken(SyntaxKind.AmpersandToken);
                    break;
                case XSharpParser.TILDE:
                    r = SyntaxFactory.MakeToken(SyntaxKind.CaretToken);
                    break;
                case XSharpParser.PIPE:
                    r = SyntaxFactory.MakeToken(SyntaxKind.BarToken);
                    break;
                case XSharpParser.LOGIC_AND:
                    r = SyntaxFactory.MakeToken(SyntaxKind.AmpersandAmpersandToken);
                    break;
                case XSharpParser.AND:
                    r = SyntaxFactory.MakeToken(SyntaxKind.AmpersandAmpersandToken);
                    break;
                case XSharpParser.LOGIC_OR:
                    r = SyntaxFactory.MakeToken(SyntaxKind.BarBarToken);
                    break;
                case XSharpParser.OR:
                    r = SyntaxFactory.MakeToken(SyntaxKind.BarBarToken);
                    break;

                case XSharpParser.ASSIGN_OP:
                    r = SyntaxFactory.MakeToken(SyntaxKind.EqualsToken);
                    break;
                case XSharpParser.ASSIGN_ADD:
                    r = SyntaxFactory.MakeToken(SyntaxKind.PlusEqualsToken);
                    break;
                case XSharpParser.ASSIGN_SUB:
                    r = SyntaxFactory.MakeToken(SyntaxKind.MinusEqualsToken);
                    break;
                //case XSharpParser.ASSIGN_EXP:
                //    kind = SyntaxKind.None;
                //    break;
                case XSharpParser.ASSIGN_MUL:
                    r = SyntaxFactory.MakeToken(SyntaxKind.AsteriskEqualsToken);
                    break;
                case XSharpParser.ASSIGN_DIV:
                    r = SyntaxFactory.MakeToken(SyntaxKind.SlashEqualsToken);
                    break;
                case XSharpParser.ASSIGN_MOD:
                    r = SyntaxFactory.MakeToken(SyntaxKind.PercentEqualsToken);
                    break;
                case XSharpParser.ASSIGN_BITAND:
                    r = SyntaxFactory.MakeToken(SyntaxKind.AmpersandToken);
                    break;
                case XSharpParser.ASSIGN_BITOR:
                    r = SyntaxFactory.MakeToken(SyntaxKind.BarEqualsToken);
                    break;
                case XSharpParser.ASSIGN_LSHIFT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.LessThanLessThanEqualsToken);
                    break;
                case XSharpParser.ASSIGN_RSHIFT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.GreaterThanGreaterThanEqualsToken);
                    break;
                case XSharpParser.ASSIGN_XOR:
                    r = SyntaxFactory.MakeToken(SyntaxKind.CaretEqualsToken);
                    break;
                case XSharpParser.DEFAULT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.QuestionQuestionToken);
                    break;
                case XSharpParser.ADDROF:
                    r = SyntaxFactory.MakeToken(SyntaxKind.AmpersandToken);
                    break;
                case XSharpParser.INC:
                    r = SyntaxFactory.MakeToken(SyntaxKind.PlusPlusToken);
                    break;
                case XSharpParser.DEC:
                    r = SyntaxFactory.MakeToken(SyntaxKind.MinusMinusToken);
                    break;
                case XSharpParser.LOGIC_NOT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ExclamationToken);
                    break;
                case XSharpParser.LOGIC_XOR:
                    r = SyntaxFactory.MakeToken(SyntaxKind.CaretToken);
                    break;
                case XSharpParser.NOT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ExclamationToken);
                    break;
                default:
                    r = SyntaxFactory.MakeToken(SyntaxKind.BadToken).WithAdditionalDiagnostics(
                        new SyntaxDiagnosticInfo(0, token.Text.Length, ErrorCode.ERR_SyntaxError, token));
                    break;
            }
            r.XNode = new TerminalNodeImpl(token);
            return r;
        }

        public static SyntaxToken SyntaxKeyword(this IToken token)
        {
            SyntaxToken r;
            switch (token.Type)
            {
                case XSharpParser.ABSTRACT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.AbstractKeyword, token.Text);
                    break;
                case XSharpParser.STATIC:
                    r = SyntaxFactory.MakeToken(SyntaxKind.StaticKeyword, token.Text);
                    break;
                case XSharpParser.INTERNAL:
                    r = SyntaxFactory.MakeToken(SyntaxKind.InternalKeyword, token.Text);
                    break;
                case XSharpParser.PUBLIC:
                    r = SyntaxFactory.MakeToken(SyntaxKind.PublicKeyword, token.Text);
                    break;
                case XSharpParser.EXPORT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.PublicKeyword, token.Text);
                    break;
                case XSharpParser.PRIVATE:
                    r = SyntaxFactory.MakeToken(SyntaxKind.PrivateKeyword, token.Text);
                    break;
                case XSharpParser.HIDDEN:
                    r = SyntaxFactory.MakeToken(SyntaxKind.PrivateKeyword, token.Text);
                    break;
                case XSharpParser.NEW:
                    r = SyntaxFactory.MakeToken(SyntaxKind.NewKeyword, token.Text);
                    break;
                case XSharpParser.PROTECTED:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ProtectedKeyword, token.Text);
                    break;
                case XSharpParser.PARTIAL:
                    r = SyntaxFactory.MakeToken(SyntaxKind.PartialKeyword, token.Text);
                    break;
                case XSharpParser.EXTERN:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ExternKeyword, token.Text);
                    break;
                case XSharpParser.UNSAFE:
                    r = SyntaxFactory.MakeToken(SyntaxKind.UnsafeKeyword, token.Text);
                    break;
                case XSharpParser.CHECKED:
                    r = SyntaxFactory.MakeToken(SyntaxKind.CheckedKeyword, token.Text);
                    break;
                case XSharpParser.UNCHECKED:
                    r = SyntaxFactory.MakeToken(SyntaxKind.UncheckedKeyword, token.Text);
                    break;
                case XSharpParser.ASYNC:
                    r = SyntaxFactory.MakeToken(SyntaxKind.AsyncKeyword, token.Text);
                    break;
                case XSharpParser.AWAIT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.AwaitKeyword, token.Text);
                    break;
                case XSharpParser.CASE:
                    r = SyntaxFactory.MakeToken(SyntaxKind.CaseKeyword, token.Text);
                    break;
                case XSharpParser.DEFAULT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.DefaultKeyword, token.Text);
                    break;
                case XSharpParser.OTHERWISE:
                    r = SyntaxFactory.MakeToken(SyntaxKind.DefaultKeyword, token.Text);
                    break;
                case XSharpParser.REF:
                    r = SyntaxFactory.MakeToken(SyntaxKind.RefKeyword, token.Text);
                    break;
                case XSharpParser.OUT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.OutKeyword, token.Text);
                    break;
                case XSharpParser.CONST:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ConstKeyword, token.Text);
                    break;
                case XSharpParser.CLASS:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ClassKeyword, token.Text);
                    break;
                case XSharpParser.STRUCTURE:
                    r = SyntaxFactory.MakeToken(SyntaxKind.StructKeyword, token.Text);
                    break;
                case XSharpParser.SEALED:
                    r = SyntaxFactory.MakeToken(SyntaxKind.SealedKeyword, token.Text);
                    break;
                case XSharpParser.VIRTUAL:
                    r = SyntaxFactory.MakeToken(SyntaxKind.VirtualKeyword, token.Text);
                    break;
                case XSharpParser.SELF:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ThisKeyword, token.Text);
                    break;
                case XSharpParser.USING:
                    r = SyntaxFactory.MakeToken(SyntaxKind.UsingKeyword, token.Text);
                    break;
                case XSharpParser.SUPER:
                    r = SyntaxFactory.MakeToken(SyntaxKind.BaseKeyword, token.Text);
                    break;
                case XSharpParser.VAR:
                    r = SyntaxFactory.Identifier("Xs$var");
                    break;
                case XSharpParser.THROW:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ThrowKeyword, token.Text);
                    break;
                case XSharpParser.TRY:
                    r = SyntaxFactory.MakeToken(SyntaxKind.TryKeyword, token.Text);
                    break;
                case XSharpParser.CATCH:
                    r = SyntaxFactory.MakeToken(SyntaxKind.CatchKeyword, token.Text);
                    break;
                case XSharpParser.FINALLY:
                    r = SyntaxFactory.MakeToken(SyntaxKind.FinallyKeyword, token.Text);
                    break;
                case XSharpParser.YIELD:
                    r = SyntaxFactory.MakeToken(SyntaxKind.YieldKeyword, token.Text);
                    break;
                case XSharpParser.VOLATILE:
                    r = SyntaxFactory.MakeToken(SyntaxKind.VolatileKeyword, token.Text);
                    break;
                case XSharpParser.INITONLY:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ReadOnlyKeyword, token.Text);
                    break;
                case XSharpParser.IMPLICIT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ImplicitKeyword, token.Text);
                    break;
                case XSharpParser.EXPLICIT:
                    r = SyntaxFactory.MakeToken(SyntaxKind.ExplicitKeyword, token.Text);
                    break;
                case XSharpParser.GLOBAL:
                    r = SyntaxFactory.MakeToken(SyntaxKind.GlobalKeyword, token.Text);
                    break;
                case XSharpParser.INSTANCE:
                    r = SyntaxFactory.MakeToken(SyntaxKind.None);
                    break;
                case XSharpParser.ASCENDING:
                    r = SyntaxFactory.MakeToken(SyntaxKind.AscendingKeyword, token.Text);
                    break;
                case XSharpParser.DESCENDING:
                    r = SyntaxFactory.MakeToken(SyntaxKind.DescendingKeyword, token.Text);
                    break;
                case XSharpParser.ACCESS:
                case XSharpParser.ALIGN:
                case XSharpParser.AS:
                case XSharpParser.ASSIGN:
                case XSharpParser.BEGIN:
                case XSharpParser.BREAK:
                //case XSharpParser.CASE:
                case XSharpParser.CAST:
                case XSharpParser.CLIPPER:
                case XSharpParser.DEFINE:
                case XSharpParser.DIM:
                case XSharpParser.DLL:
                case XSharpParser.DO:
                case XSharpParser.DOWNTO:
                case XSharpParser.ELSE:
                case XSharpParser.ELSEIF:
                case XSharpParser.END:
                case XSharpParser.ENDCASE:
                case XSharpParser.ENDDO:
                case XSharpParser.ENDIF:
                case XSharpParser.EXIT:
                //case XSharpParser.EXPORT:
                case XSharpParser.FASTCALL:
                case XSharpParser.FIELD:
                case XSharpParser.FOR:
                case XSharpParser.FUNCTION:
                //case XSharpParser.HIDDEN:
                case XSharpParser.IF:
                case XSharpParser.IIF:
                case XSharpParser.INHERIT:
                case XSharpParser.IN:
                case XSharpParser.IS:
                case XSharpParser.LOCAL:
                case XSharpParser.LOOP:
                case XSharpParser.MEMBER:
                case XSharpParser.METHOD:
                case XSharpParser.NEXT:
                //case XSharpParser.OTHERWISE:
                case XSharpParser.PASCAL:
                //case XSharpParser.PRIVATE:
                case XSharpParser.PROCEDURE:
                //case XSharpParser.PROTECTED:
                //case XSharpParser.PUBLIC:
                case XSharpParser.RECOVER:
                case XSharpParser.RETURN:
                case XSharpParser.SEQUENCE:
                case XSharpParser.SIZEOF:
                case XSharpParser.STEP:
                case XSharpParser.STRICT:
                case XSharpParser.THISCALL:
                case XSharpParser.TO:
                case XSharpParser.TYPEOF:
                case XSharpParser.UNION:
                case XSharpParser.UPTO:
                case XSharpParser.WHILE:
                case XSharpParser.AUTO:
                case XSharpParser.CONSTRUCTOR:
                //case XSharpParser.CONST:
                case XSharpParser.DELEGATE:
                case XSharpParser.DESTRUCTOR:
                case XSharpParser.ENUM:
                case XSharpParser.EVENT:
                case XSharpParser.FOREACH:
                case XSharpParser.GET:
                case XSharpParser.IMPLEMENTS:
                case XSharpParser.IMPLIED:
                case XSharpParser.INTERFACE:
                //case XSharpParser.INTERNAL:
                case XSharpParser.LOCK:
                case XSharpParser.NAMESPACE:
                //case XSharpParser.NEW:
                case XSharpParser.OPERATOR:
                //case XSharpParser.OUT:
                //case XSharpParser.PARTIAL:
                case XSharpParser.PROPERTY:
                case XSharpParser.REPEAT:
                case XSharpParser.SCOPE:
                case XSharpParser.SET:
                case XSharpParser.UNTIL:
                case XSharpParser.VALUE:
                case XSharpParser.VOSTRUCT:
                case XSharpParser.ASSEMBLY:
                //case XSharpParser.ASYNC:
                //case XSharpParser.AWAIT:
                //case XSharpParser.CHECKED:
                //case XSharpParser.DEFAULT:
                //case XSharpParser.EXTERN:
                case XSharpParser.MODULE:
                case XSharpParser.SWITCH:
                //case XSharpParser.UNCHECKED:
                //case XSharpParser.UNSAFE:
                case XSharpParser.WHERE:
                case XSharpParser.FROM:
                case XSharpParser.LET:
                case XSharpParser.JOIN:
                case XSharpParser.ORDERBY:
                case XSharpParser.INTO:
                case XSharpParser.ON:
                    r = SyntaxFactory.Identifier(token.Text);
                    break;
                default:
                    r = SyntaxFactory.MakeToken(SyntaxKind.BadToken).WithAdditionalDiagnostics(
                        new SyntaxDiagnosticInfo(0, token.Text.Length, ErrorCode.ERR_SyntaxError, token));
                    break;
            }
            r.XNode = new TerminalNodeImpl(token);
            return r;
        }

        public static SyntaxKind OrderingKind(this IToken token)
        {
            SyntaxKind r;
            switch (token.Type)
            {
                case XSharpParser.ASCENDING:
                    r = SyntaxKind.AscendingOrdering;
                    break;
                case XSharpParser.DESCENDING:
                    r = SyntaxKind.DescendingOrdering;
                    break;
                default:
                    throw new InvalidOperationException();
            }
            return r;
        }

        public static SyntaxKind SwitchLabelKind(this IToken token)
        {
            SyntaxKind r;
            switch (token.Type)
            {
                case XSharpParser.CASE:
                    r = SyntaxKind.CaseSwitchLabel;
                    break;
                case XSharpParser.DEFAULT:
                    r = SyntaxKind.DefaultSwitchLabel;
                    break;
                case XSharpParser.OTHERWISE:
                    r = SyntaxKind.DefaultSwitchLabel;
                    break;
                default:
                    throw new InvalidOperationException();
            }
            return r;
        }

        public static SyntaxKind ConstraintKind(this IToken token)
        {
            SyntaxKind r;
            switch (token.Type)
            {
                case XSharpParser.CLASS:
                    r = SyntaxKind.ClassConstraint;
                    break;
                case XSharpParser.STRUCTURE:
                    r = SyntaxKind.StructConstraint;
                    break;
                default:
                    throw new InvalidOperationException();
            }
            return r;
        }

        public static SyntaxKind CtorInitializerKind(this IToken token)
        {
            SyntaxKind r;
            switch (token.Type)
            {
                case XSharpParser.SELF:
                    r = SyntaxKind.ThisConstructorInitializer;
                    break;
                case XSharpParser.SUPER:
                    r = SyntaxKind.BaseConstructorInitializer;
                    break;
                default:
                    throw new InvalidOperationException();
            }
            return r;
        }

        public static SyntaxKind AccessorKind(this IToken token)
        {
            SyntaxKind r;
            switch (token.Type)
            {
                case XSharpParser.GET:
                    r = SyntaxKind.GetAccessorDeclaration;
                    break;
                case XSharpParser.SET:
                    r = SyntaxKind.SetAccessorDeclaration;
                    break;
                default:
                    throw new InvalidOperationException();
            }
            return r;
        }

        public static SyntaxKind StatementKind(this IToken token)
        {
            SyntaxKind r;
            switch (token.Type)
            {
                case XSharpParser.UNSAFE:
                    r = SyntaxKind.UnsafeStatement;
                    break;
                case XSharpParser.CHECKED:
                    r = SyntaxKind.CheckedStatement;
                    break;
                case XSharpParser.UNCHECKED:
                    r = SyntaxKind.UncheckedStatement;
                    break;
                default:
                    throw new InvalidOperationException();
            }
            return r;
        }

        public static SyntaxKind ExpressionKind(this IToken token)
        {
            SyntaxKind r;
            switch (token.Type)
            {
                case XSharpParser.CHECKED:
                    r = SyntaxKind.CheckedExpression;
                    break;
                case XSharpParser.UNCHECKED:
                    r = SyntaxKind.UncheckedExpression;
                    break;
                default:
                    throw new InvalidOperationException();
            }
            return r;
        }

        public static SyntaxKind ExpressionKindLiteral(this IToken token)
        {
            SyntaxKind r;
            switch (token.Type)
            {
                case XSharpParser.TRUE_CONST:
                    r = SyntaxKind.TrueLiteralExpression;
                    break;
                case XSharpParser.FALSE_CONST:
                    r = SyntaxKind.FalseLiteralExpression;
                    break;
                case XSharpParser.CHAR_CONST:
                    r = SyntaxKind.CharacterLiteralExpression;
                    break;
                case XSharpParser.STRING_CONST:
                    r = SyntaxKind.StringLiteralExpression;
                    break;
                case XSharpParser.SYMBOL_CONST:
                    r = SyntaxKind.StringLiteralExpression;
                    break;
                case XSharpParser.HEX_CONST:
                    r = SyntaxKind.NumericLiteralExpression;
                    break;
                case XSharpParser.BIN_CONST:
                    r = SyntaxKind.NumericLiteralExpression;
                    break;
                case XSharpParser.REAL_CONST:
                    r = SyntaxKind.NumericLiteralExpression;
                    break;
                case XSharpParser.INT_CONST:
                    r = SyntaxKind.NumericLiteralExpression;
                    break;
                case XSharpParser.DATE_CONST:
                    r = SyntaxKind.NumericLiteralExpression;
                    break;
                case XSharpParser.NIL:
                case XSharpParser.NULL:
                case XSharpParser.NULL_ARRAY:
                case XSharpParser.NULL_CODEBLOCK:
                case XSharpParser.NULL_DATE:
                case XSharpParser.NULL_OBJECT:
                case XSharpParser.NULL_PSZ:
                case XSharpParser.NULL_PTR:
                case XSharpParser.NULL_STRING:
                case XSharpParser.NULL_SYMBOL:
                    r = SyntaxKind.NullLiteralExpression;
                    break;
                default:
                    throw new InvalidOperationException();
            }
            return r;
        }

        public static SyntaxKind ExpressionKindBinaryOp(this IToken token)
        {
            SyntaxKind r;
            switch (token.Type)
            {
                //case XSharpParser.EXP:
                //    r = SyntaxKind.None;
                //    break;
                case XSharpParser.PLUS:
                    r = SyntaxKind.AddExpression;
                    break;
                case XSharpParser.MINUS:
                    r = SyntaxKind.SubtractExpression;
                    break;
                case XSharpParser.MULT:
                    r = SyntaxKind.MultiplyExpression;
                    break;
                case XSharpParser.DIV:
                    r = SyntaxKind.DivideExpression;
                    break;
                case XSharpParser.MOD:
                    r = SyntaxKind.ModuloExpression;
                    break;
                case XSharpParser.LSHIFT:
                    r = SyntaxKind.LeftShiftExpression;
                    break;
                case XSharpParser.RSHIFT:
                    r = SyntaxKind.RightShiftExpression;
                    break;
                case XSharpParser.LT:
                    r = SyntaxKind.LessThanExpression;
                    break;
                case XSharpParser.LTE:
                    r = SyntaxKind.LessThanOrEqualExpression;
                    break;
                case XSharpParser.GT:
                    r = SyntaxKind.GreaterThanExpression;
                    break;
                case XSharpParser.GTE:
                    r = SyntaxKind.GreaterThanOrEqualExpression;
                    break;
                case XSharpParser.EQ:
                    r = SyntaxKind.EqualsExpression;
                    break;
                case XSharpParser.EEQ:
                    r = SyntaxKind.EqualsExpression;
                    break;
                case XSharpParser.NEQ:
                    r = SyntaxKind.NotEqualsExpression;
                    break;
                //case XSharpParser.SUBSTR:
                //    r = SyntaxKind.None;
                //    break;
                case XSharpParser.AMP:
                    r = SyntaxKind.BitwiseAndExpression;
                    break;
                case XSharpParser.TILDE:
                    r = SyntaxKind.ExclusiveOrExpression;
                    break;
                case XSharpParser.PIPE:
                    r = SyntaxKind.BitwiseOrExpression;
                    break;
                case XSharpParser.LOGIC_AND:
                    r = SyntaxKind.LogicalAndExpression;
                    break;
                case XSharpParser.AND:
                    r = SyntaxKind.LogicalAndExpression;
                    break;
                case XSharpParser.LOGIC_OR:
                    r = SyntaxKind.LogicalOrExpression;
                    break;
                case XSharpParser.OR:
                    r = SyntaxKind.LogicalOrExpression;
                    break;

                case XSharpParser.ASSIGN_OP:
                    r = SyntaxKind.SimpleAssignmentExpression;
                    break;
                case XSharpParser.ASSIGN_ADD:
                    r = SyntaxKind.AddAssignmentExpression;
                    break;
                case XSharpParser.ASSIGN_SUB:
                    r = SyntaxKind.SubtractAssignmentExpression;
                    break;
                //case XSharpParser.ASSIGN_EXP:
                //    r = SyntaxKind.None;
                //    break;
                case XSharpParser.ASSIGN_MUL:
                    r = SyntaxKind.MultiplyAssignmentExpression;
                    break;
                case XSharpParser.ASSIGN_DIV:
                    r = SyntaxKind.DivideAssignmentExpression;
                    break;
                case XSharpParser.ASSIGN_MOD:
                    r = SyntaxKind.ModuloAssignmentExpression;
                    break;
                case XSharpParser.ASSIGN_BITAND:
                    r = SyntaxKind.AndAssignmentExpression;
                    break;
                case XSharpParser.ASSIGN_BITOR:
                    r = SyntaxKind.OrAssignmentExpression;
                    break;
                case XSharpParser.ASSIGN_LSHIFT:
                    r = SyntaxKind.LeftShiftAssignmentExpression;
                    break;
                case XSharpParser.ASSIGN_RSHIFT:
                    r = SyntaxKind.RightShiftAssignmentExpression;
                    break;
                case XSharpParser.ASSIGN_XOR:
                    r = SyntaxKind.ExclusiveOrAssignmentExpression;
                    break;
                case XSharpParser.DEFAULT:
                    r = SyntaxKind.CoalesceExpression;
                    break;
                default:
                    throw new InvalidOperationException();
            }
            return r;
        }

        public static SyntaxKind ExpressionKindPrefixOp(this IToken token)
        {
            SyntaxKind r;
            switch (token.Type)
            {
                case XSharpParser.PLUS:
                    r = SyntaxKind.UnaryPlusExpression;
                    break;
                case XSharpParser.MINUS:
                    r = SyntaxKind.UnaryMinusExpression;
                    break;
                case XSharpParser.TILDE:
                    r = SyntaxKind.BitwiseNotExpression;
                    break;
                case XSharpParser.ADDROF:
                    r = SyntaxKind.AddressOfExpression;
                    break;
                case XSharpParser.INC:
                    r = SyntaxKind.PreIncrementExpression;
                    break;
                case XSharpParser.DEC:
                    r = SyntaxKind.PreDecrementExpression;
                    break;
                case XSharpParser.LOGIC_NOT:
                    r = SyntaxKind.LogicalNotExpression;
                    break;
                case XSharpParser.LOGIC_XOR:
                    r = SyntaxKind.BitwiseNotExpression;
                    break;
                case XSharpParser.NOT:
                    r = SyntaxKind.LogicalNotExpression;
                    break;
                default:
                    throw new InvalidOperationException();
            }
            return r;
        }

        public static SyntaxKind ExpressionKindPostfixOp(this IToken token)
        {
            SyntaxKind r;
            switch (token.Type)
            {
                case XSharpParser.INC:
                    r = SyntaxKind.PostIncrementExpression;
                    break;
                case XSharpParser.DEC:
                    r = SyntaxKind.PostDecrementExpression;
                    break;
                default:
                    throw new InvalidOperationException();
            }
            return r;
        }

        public static void AddCheckUnique(this SyntaxListBuilder list, SyntaxToken t)
        {
            if (t.Kind != SyntaxKind.None) {
                if(list.Any(t.Kind)) {
                    t = t.WithAdditionalDiagnostics(
                        new SyntaxDiagnosticInfo(t.GetLeadingTriviaWidth(), t.Width, ErrorCode.ERR_DuplicateModifier, t));
                }
                list.Add(t);
            }
        }

        public static void FixDefaultVisibility(this SyntaxListBuilder list)
        {
            for (int i = 0; i < list.Count; i++) {
                var item = list[i];
                if (SyntaxFacts.IsAccessibilityModifier(item.Kind))
                    return;
            }
            list.Add(SyntaxFactory.MakeToken(SyntaxKind.PublicKeyword));
        }

        public static int GetVisibilityLevel(this SyntaxListBuilder list)
        {
            if (list.Any(SyntaxKind.PublicKeyword))
                return 0;
            if (list.Any(SyntaxKind.ProtectedKeyword)) {
                if (list.Any(SyntaxKind.InternalKeyword))
                    return 1;
                else
                    return 2;
            }
            if (list.Any(SyntaxKind.InternalKeyword))
                return 2;
            if (list.Any(SyntaxKind.PrivateKeyword))
                return 3;
            return 0;
        }
    }
}