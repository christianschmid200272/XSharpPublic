using System;
using System.Collections.Generic;
using System.Linq;
using System.Diagnostics;
using System.Text;
using System.Threading.Tasks;

namespace XSharp.MacroCompiler
{
    using Syntax;
    using static Compilation;

    partial class Parser
    {
        // Lexer to generate input
        Lexer _Lexer;

        // Input source
        IList<Token> _Input;

        // Configuration
        MacroOptions _options;
        bool AllowMissingSyntax { get { return _options.AllowMissingSyntax; } }
        bool AllowExtraneousSyntax { get { return _options.AllowExtraneousSyntax; } }

        // State
        int _index = 0;

        internal Parser(Lexer lexer, MacroOptions options)
        {
            _Lexer = lexer;
            _Input = lexer.AllTokens();
            _options = options;
        }

        Token Lt()
        {
            return _index < _Input.Count ? _Input[_index] : null;
        }

        TokenType La()
        {
            return _index < _Input.Count ? _Input[_index].type : TokenType.EOF;
        }

        TokenType La(int n)
        {
            return (_index + n - 1) < _Input.Count ? _Input[_index + n - 1].type : TokenType.EOF;
        }

        bool Eoi()
        {
            return _index >= _Input.Count;
        }

        void Consume()
        {
            _index++;
        }

        void Consume(int n)
        {
            _index += n;
        }

        int Mark()
        {
            return _index;
        }

        void Rewind(int pos)
        {
            _index = pos;
        }

        Token ConsumeAndGet()
        {
            var t = _Input[_index];
            _index++;
            return t;
        }

        bool Expect(TokenType c)
        {
            if (La() == c)
            {
                Consume();
                return true;
            }
            return false;
        }

        bool ExpectAny(params TokenType[] c)
        {
            if (c.Contains(La()))
            {
                Consume();
                return true;
            }
            return false;
        }

        bool ExpectAndGet(TokenType c, out Token t)
        {
            if (La() == c)
            {
                t = ConsumeAndGet();
                return true;
            }
            t = null;
            return false;
        }
        Token ExpectAndGetAny(params TokenType[] c)
        {
            if (c.Contains(La()))
            {
                return ConsumeAndGet();
            }
            return null;
        }

        bool Require(bool p, ErrorCode error, params object[] args)
        {
            if (!p)
            {
                throw Error(Lt(), error, args);
            }
            return p;
        }

        T Require<T>(T n, ErrorCode error, params object[] args)
        {
            if (n == null)
            {
                throw Error(Lt(), error, args);
            }
            return n;
        }

        T Require<T>(T n, Token t, ErrorCode error, params object[] args)
        {
            if (n == null)
            {
                throw Error(t, error, args);
            }
            return n;
        }

        T RequireEnd<T>(T n, ErrorCode error, params object[] args)
        {
            Expect(TokenType.EOS);
            if (La() != TokenType.EOF)
            {
                throw Error(Lt(), error, args);
            }
            return n;
        }

        Token RequireId()
        {
            if (La() == TokenType.ID || TokenAttr.IsSoftKeyword(La()))
                return ConsumeAndGet();
            throw Error(Lt(), ErrorCode.Expected, "identifier");
        }

        internal Codeblock ParseMacro()
        {
            var p = new List<IdExpr>();
            if (La() == TokenType.LCURLY && (La(2) == TokenType.PIPE || La(2) == TokenType.OR))
                return RequireEnd(ParseCodeblock(), ErrorCode.Unexpected, Lt());

            var l = ParseExprList();
            if (l != null)
            {
                if (AllowExtraneousSyntax) while (ExpectAny(TokenType.RPAREN)) { }
                return RequireEnd(new Codeblock(null, new ReturnStmt(l)), ErrorCode.Unexpected, Lt());
            }

            return null;
        }

        internal StmtBlock ParseScript()
        {
            return ParseStatementBlock();
        }
    }
}
