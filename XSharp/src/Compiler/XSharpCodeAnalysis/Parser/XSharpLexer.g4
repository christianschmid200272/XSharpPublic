lexer grammar XSharpLexer;

/*
 * Lexer Rules
*/

@lexer::members
{
	int _lastToken = NL;
	public override IToken NextToken()
	{
		IToken iToken = base.NextToken();
		_lastToken = iToken.Type;
		return iToken;
	}
	int LastToken
	{
		get {return _lastToken;}
	}
	bool _Four = true;
	public bool AllowFourLetterAbbreviations
	{
		get {return _Four;}
		set {_Four = value;}
	}
	bool _OldComment = true;
	public bool AllowOldStyleComments
	{
		get {return _OldComment;}
		set {_OldComment = value;}
	}
}

options	{ 
			language=CSharp; 
		}



/*
 * Lexer Rules
 */

// Keywords
// Old (VO) Keywords can have 4 letter abbreviations. This can be enabled/disabled with the
// AllowFourLetterAbbreviations property of the Lexer, which sets the protected field _Four.
// New (Vulcan) Keywords only full names
//

ACCESS				: A C C E S S
					| {_Four}?  A C C E (S)?
					;
ALIGN				: A L I G N
					| {_Four}?  A L I G
					;
AS					: A S ;
ASSIGN				: A S S I G N
					| {_Four}?  A S S I (G)?
					;
BEGIN				: B E G I N
					| {_Four}?  B E G I
					;
BREAK				: B R E A K
					| {_Four}?  B R E A
					;
CASE				: C A S E;
CAST				: '_' C A S T ;
CLASS				: C L A S S
					| {_Four}?  C L A S
					;
CLIPPER				: C L I P P E R
					| {_Four}?  C L I P (P(E)?)?
					;
DEFINE				: D E F I N E
					| {_Four}?  D E F I (N)?
					;
DIM					: D I M ;
DLL					: '_' D L L ;
DO					: D O ;
DOWNTO				: D O W N T O
					| {_Four}?  D O W N (T)?
					;
ELSE				: E L S E;
ELSEIF				: E L S E I F
					| {_Four}?  E L S E I
					;
END					: E N D ;
ENDCASE				: E N D C A S E
					| {_Four}?  E N D C(A(S)?)?
					;
ENDDO				: E N D D O
					| {_Four}?  E N D D
					;
ENDIF				: E N D I F
					| {_Four}?  E N D I
					;
EXIT				: E X I T ;
EXPORT				: E X P O R T
					| {_Four}?  E X P O (R)?
					;
FASTCALL			: F A S T C A L L
					| {_Four}?  F A S T (C(A(L)?)?)?
					;

FIELD				: '_'? F I E L D ;
FOR					: F O R ;
FUNCTION			: F U N C T I O N
					| {_Four}?  F U N C (T(I(O)?)?)?
					;
GLOBAL				: G L O B A L
					| {_Four}?  G L O B (A)?
					;
HIDDEN				: H I D D E N
					| {_Four}?  H I D D (E)?
					;
IF					: I F ;
IIF					: I I F;
INHERIT				: I N H E R I T
					| { _Four}? I N H E (R(I)?)?
					;
INSTANCE			: I N S T A N C E
					| { _Four}? I N S T (A(N(C)?)?)?
					;
IN					: I N ;
IS					: I S ;
LOCAL				: L O C A L
					| {_Four}?  L O C A
					;
LOOP				: L O O P ;
MEMBER				: M E M B E R
					| {_Four}?  M E M B (E)?
					;
MEMVAR              : M E M V A R 
                    | {_Four}?  M E M V (A)?
					; 
METHOD				: M E T H O D
					| {_Four}?  M E T H (O)?
					;
NEXT				: N E X T ;
OTHERWISE			: O T H E R W I S E
					| {_Four}?  O T H E (R(W(I(S)?)?)?)?
                    ;
PARAMETERS			: P A R A M E T E R S
					| {_Four}?  P A R A (M(E(T(E(R)?)?)?)?)?
					;
PASCAL				: P A S C A L
					| {_Four}?  P A S C (A)?
					;
PRIVATE				: P R I V A T E
					| {_Four}?  P R I V (A ( T)?)?
					;
PROCEDURE			: P R O C E D U R E
					| { _Four}? P R O C (E(D(U(R)?)?)?)?
					;
PROTECTED			: P R O T E C T E D
					| { _Four}? P R O T (E(C(T(E)?)?)?)?
					;
PUBLIC				: P U B L I C
					| { _Four}? P U B L (I)?
					;
RECOVER				: R E C O V E R
					| { _Four}? R E C O (V(E)?)?
					;
RETURN				: R E T U R N
					| { _Four}? R E T U (R)?
					;
SELF				: S E L F ;
SEQUENCE			: S E Q U E N C E
					| { _Four}? S E Q U (E(N(C)?)?)?
					;
SIZEOF				: '_'? S I Z E O F ;
STATIC				: S T A T I C
					| { _Four}? S T A T (I)?
					;
STEP				: S T E P ;
STRICT				: S T R I C T
					| { _Four}? S T R I (C)?
					;
SUPER				: S U P E R
					| { _Four}? S U P E
					;
THISCALL			: T H I S C A L L
					| { _Four}? T H I S (C(A(L)?)?)?
					;
TO					: T O ;
TYPEOF				: '_'? T Y P E O F ;
UNION				: U N I O N
					| { _Four}? U N I O
					;
UPTO				: U P T O ;
USING				: U S I N G
					| { _Four}? U S I N
					;
WHILE				: W H I L E
					| { _Four}? W H I L
					;


// New Vulcan Keywords (no 4 letter abbreviations)
// Should also all be part of the identifier rule
ABSTRACT			: A B S T R A C T ;
AUTO				: A U T O ;
CATCH				: C A T C H ;
CONSTRUCTOR			: C O N S T R U C T O R ;
CONST				: C O N S T ;
DELEGATE			: D E L E G A T E ;
DESTRUCTOR			: D E S T R U C T O R ;
ENUM				: E N U M ;
EVENT				: E V E N T ;
EXPLICIT			: E X P L I C I T ;
FINALLY				: F I N A L L Y ;
FOREACH				: F O R E A C H ;
GET					: G E T ;
IMPLEMENTS			: I M P L E M E N T S ;
IMPLICIT			: I M P L I C I T ;
IMPLIED				: I M P L I E D ;
INITONLY			: I N I T O N L Y ;
INTERFACE			: I N T E R F A C E ;
INTERNAL			: I N T E R N A L ;
LOCK				: L O C K ;
NAMESPACE			: N A M E S P A C E ;
NEW					: N E W ;
OPERATOR			: O P E R A T O R ;
OUT					: O U T ;
PARTIAL				: P A R T I A L ;
PROPERTY			: P R O P E R T Y ;
REPEAT				: R E P E A T ;
SCOPE				: S C O P E ;
SEALED				: S E A L E D ;
SET					: S E T ;
STRUCTURE			: S T R U C T U R E ;					
THROW				: T H R O W ;
TRY					: T R Y ;
UNTIL				: U N T I L ;
VALUE				: V A L U E ;
VIRTUAL				: V I R T U A L ;
VOSTRUCT			: V O S T R U C T ;


// New XSharp Keywords (no 4 letter abbreviations)
// Should also all be part of the identifier rule

ASYNC				: A S Y N C;
AWAIT				: A W A I T ;
CHECKED				: C H E C K E D;
DEFAULT				: D E F A U L T;
EXTERN				: E X T E R N ;
PARAMS				: P A R A M S ;
SWITCH				: S W I T C H ;
UNCHECKED			: U N C H E C K E D;
UNSAFE				: U N S A F E;
VAR                 : V A R ;
VOLATILE			: V O L A T I L E ;
WHERE				: W H E R E ;
YIELD               : Y I E L D ;



// Predefined types
ARRAY				: A R R A Y
					| { _Four}? A R R A
					;
BYTE				: B Y T E ;
CHAR				: C H A R ;
CODEBLOCK			: C O D E B L O C K
					| { _Four}? C O D E (B(L(O(C)?)?)?)?
					;
DATE				: D A T E ;
DWORD				: D W O R D
					| { _Four}? D W O R
					;
FLOAT				: F L O A T
					| { _Four}? F L O A
					;
INT					: I N T ;
LOGIC				: L O G I C
					| { _Four}? L O G I
					;

LONGINT				: L O N G I N T
					| { _Four}? L O N G (I(N)?)?
					;

OBJECT				: O B J E C T
					| { _Four}? O B J E (C)?
					;
PSZ					: P S Z ;
PTR					: P T R ;
REAL4				: R E A L '4' ;
REAL8				: R E A L '8' ;
REF					: R E F ;
SHORTINT			: S H O R T I N T
					| { _Four}? S H O R (T(I(N)?)?)?
					;
STRING				: S T R I N G
					| { _Four}? S T R I (N)?
					;
SYMBOL				: S Y M B O L
					| { _Four}? S Y M B (O)?
					;
USUAL				: U S U A L
					| { _Four}? U S U A
					;
VOID				: V O I D ;
WORD				: W O R D ;

// Vulcan Types
INT64				: I N T '6' '4' ;
UINT64				: U I N T '6' '4' ;


// Null values
NIL					: N I L ;
NULL				: N U L L ;
NULL_ARRAY			: N U L L '_' A R R A Y ;
NULL_CODEBLOCK		: N U L L '_' C O D E B L O C K ;
NULL_DATE			: N U L L '_' D A T E ;
NULL_OBJECT			: N U L L '_' O B J E C T ;
NULL_PSZ			: N U L L '_' P S Z ;
NULL_PTR			: N U L L '_' P T R  ;
NULL_STRING			: N U L L '_' S T R I N G ;
NULL_SYMBOL			: N U L L '_' S Y M B O L ;

// Logics
FALSE_CONST			: F A L S E
					| '.' F '.'
					| '.' N '.'
					;

TRUE_CONST			: T R U E
					| '.' T '.'
					| '.' Y '.'
					;

// Operators
LOGIC_AND			: '.' A N D '.' ;
LOGIC_OR			: '.' O R '.'   ;
LOGIC_NOT			: '.' N O T '.' ;
LOGIC_XOR			: '.' X O R '.' ;

// Prefix and postfix Operators
INC					: '++' ;
DEC					: '--' ;

// Boolean operators
NOT					: '!'  ;
AND					: '&&' ;
OR					: '||' ;

// Unary & binary operators
PLUS				: '+';
MINUS				: '-' ;
DIV					: '/' ;
MOD					: '%';
EXP					: '^';
LSHIFT				: '<<' ;
RSHIFT				: '>>' ;
TILDE				: '~';
MULT				: '*' ;
QMARK				: '?' ;

// Assignments
ASSIGN_OP     : ':=' ;
ASSIGN_ADD    : '+=' ;
ASSIGN_SUB    : '-=' ;
ASSIGN_EXP    : '^=' ;
ASSIGN_MUL    : '*=' ;
ASSIGN_DIV    : '/=' ;
ASSIGN_MOD    : '%=' ;
ASSIGN_BITAND : '&=';
ASSIGN_BITOR  : '|=';
ASSIGN_LSHIFT : '<<=';
ASSIGN_RSHIFT : '>>=';
ASSIGN_XOR    : '~=';

// Relational operators
LT			: '<' ;
LTE			: '<=' ;
GT			: '>' ;
GTE			: '>=' ;
EQ			: '=' ;
EEQ			: '==' ;
SUBSTR		: '$'	;
NEQ			: '<>'
			| '!='
			;

// Misc Lexical Elements
LPAREN      : '(' ;
RPAREN		: ')' ;
LCURLY		: '{' ;
RCURLY		: '}' ;
LBRKT		: '[' ;
RBRKT		: ']' ;
COLON		: ':' ;
COMMA		: ',' ;
PIPE		: '|' ;
AMP			: '&' ;
ADDROF		: '@' ;
ALIAS		: '->';
DOT			: '.' ;

// Numeric & date constants
HEX_CONST	: '0' X ( HEX_DIGIT )+ ( U | L )?;
BIN_CONST	: '0' B ( [0-1] )+ ( U )?;
INT_CONST	:  ( DIGIT )+ ( U | L )? ;
DATE_CONST  : ( DIGIT ( DIGIT ( DIGIT ( DIGIT )? )? )? )? DOT DIGIT ( DIGIT )? DOT DIGIT ( DIGIT )?;			// 2015.07.15
REAL_CONST  : ( ( DIGIT )+ )? DOT ( DIGIT )* ( 'e' ( '+' | '-' )? ( DIGIT )+ )? ( S | D | M )?;

//DECIMAL_CONST;                         // a literal floating point number followed by 'm'


PPINCLUDE		: {LastToken == NL }? '#' I N C L U D E		(~(  '\n' | '\r' ) )* -> channel(HIDDEN) ;
PPREGION		: {LastToken == NL }? '#' R E G I O N		(~(  '\n' | '\r' ) )* -> channel(HIDDEN) ;
PPENDREGION		: {LastToken == NL }? '#' E N D R E G I O N (~(  '\n' | '\r' ) )* -> channel(HIDDEN) ;
PPIFDEF			: {LastToken == NL }? '#' I F D E F			(~(  '\n' | '\r' ) )* -> channel(HIDDEN) ;
PPIF			: {LastToken == NL }? '#' I F				(~(  '\n' | '\r' ) )* -> channel(HIDDEN) ;
PPELSEIF		: {LastToken == NL }? '#' E L S E I F		(~(  '\n' | '\r' ) )* -> channel(HIDDEN) ;
PPENDIF			: {LastToken == NL }? '#' E N D I F			(~(  '\n' | '\r' ) )* -> channel(HIDDEN) ;
			

SYMBOL_CONST: '#' [a-z_A-Z] ([a-z_A-Z0-9])*;


STRING_CONST: '"' ( ~( '"' | '\n' | '\r' ) )* '"'			// Double quoted string
			| '\'' ( ~( '\'' | '\n' | '\r' ) )* '\''		// Single quoted string
			;

WS			:	(' ' |  '\t' |	'\r') -> channel(HIDDEN)
			;


// Old Dbase Style Comments &&  and * at begin of line can be enabled with
// the Lexer Property AllowOldStyleComments

SL_COMMENT	:( '/' '/' ( ~(  '\n' | '\r' ) )*
			| {_OldComment}? '&' '&' ( ~(  '\n' | '\r' ) )*
			| {_OldComment && LastToken == NL }? '*' ( ~(  '\n' | '\r' ) )*)	-> channel(HIDDEN)
			;


ML_COMMENT  : '/' '*' .*? '*' '/'						-> channel(HIDDEN)
			;

NL						: '\n' ;

// The ID rule must be last to make sure that it does not 'eat' the keywords

ID						: ID_PART ;

UNRECOGNIZED			: . ;

// Lexer fragments

fragment DIGIT			: [0-9];
fragment HEX_DIGIT		: [0-9a-fA-F];
fragment ID_PART		: IDStartChar IDChar*
						;

fragment IDChar			: IDStartChar
						| '0'..'9'
						| '\u00B7'
						| '\u0300'..'\u036F'
						| '\u203F'..'\u2040'
						;

fragment IDStartChar	: 'A'..'Z' | 'a'..'z'
						| '_'
						| '\u00C0'..'\u00D6'
						| '\u00D8'..'\u00F6'
						| '\u00F8'..'\u02FF'
						| '\u0370'..'\u037D'
						| '\u037F'..'\u1FFF'
						| '\u200C'..'\u200D'
						;

fragment A: 'a' | 'A';
fragment B: 'b' | 'B';
fragment C: 'c' | 'C';
fragment D: 'd' | 'D';
fragment E: 'e' | 'E';
fragment F: 'f' | 'F';
fragment G: 'g' | 'G';
fragment H: 'h' | 'H';
fragment I: 'i' | 'I';
fragment J: 'j' | 'J';
fragment K: 'k' | 'K';
fragment L: 'l' | 'L';
fragment M: 'm' | 'M';
fragment N: 'n' | 'N';
fragment O: 'o' | 'O';
fragment P: 'p' | 'P';
fragment Q: 'q' | 'Q';
fragment R: 'r' | 'R';
fragment S: 's' | 'S';
fragment T: 't' | 'T';
fragment U: 'u' | 'U';
fragment V: 'v' | 'V';
fragment W: 'w' | 'W';
fragment X: 'x' | 'X';
fragment Y: 'y' | 'Y';
fragment Z: 'z' | 'Z';
