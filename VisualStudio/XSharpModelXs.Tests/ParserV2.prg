﻿


USING System
USING System.Collections.Generic
USING System.Text
USING XSharpModel
USING Xunit.Abstractions
USING LanguageService.SyntaxTree


FUNCTION Parse2( tokens AS ITokenStream) AS VOID
	VAR parse := Parserv2{ }
	parse:Parse( tokens, TRUE )
	
	RETURN	
