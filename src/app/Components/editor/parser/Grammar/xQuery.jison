 /*---------------------------IMPORTS-------------------------------*/
%{
    let valDeclaration = '';
    let valTag = '';
    let valInside = '';
    const {Error_} = require('../Error');
    const {errores} = require('../Errores');
    const {NodoXML} = require('../Nodes/NodoXml')
    // Expresiones

     const {Relational, RelationalOption} = require('../Expression/Relational');
%}

%lex
%options case-sensitive


number  [0-9]+
divsign ('/')('/')?
dir     ('.')('.')?
orsign ('|')('|')?
decimal [0-9]+("."[0-9]+)?
string  ([\"][^"]*[\"])
string2  ([\'][^\']*[\'])

ancestor ('ancestor')('-or-self')?
following ('following')('-sibling')?
preceding ('preceding')('-sibling')?

%%
\s+                   /* skip whitespace */

{decimal}                  return 'DECIMAL'
{number}                  return 'NUMBER'
{string}                      return 'STRING'
{string2}                      return 'STRING2'
{divsign}                    return 'DIVSIGN'
{dir}                            return 'DIR'
{ancestor}                  return 'ANCESTOR'
{following}                  return 'FOLLOWING'
{preceding}                return 'PRECEDING'
{orsign}                return 'ORSIGN'

"@"                     return '@'
"*"                     return '*'
"::"                     return '::'
":="                    return ':='
"-"                     return '-'
"+"                     return '+'
","                     return ','

"<="                      return '<='
">="                      return '>='
"<"                        return '<'
">"                        return '>'
"!="                       return '!='
"="                        return '='
"or"                       return 'OR'
"and"                    return 'AND'
"mod"                   return 'MOD'
"div"                      return 'DIV'

"("                     return '('
")"                     return ')' 
"["                     return '['
"]"                     return ']'

"child"                        return 'CHILD'
"attribute"                  return 'ATTR'
"descendant"             return 'DESCENDANT'
"namespace"              return 'NAMESPACE'
"parent"                     return 'PARENT'
'self'                           return 'SELF'
"text"                         return 'TEXT'
"last"                         return 'LAST'
"position"                 return 'POSITION'
"node"                       return 'NODE'
"eq"                            return 'EQ'
"ne"                            return 'NE'
"lt"                            return 'LT'
"le"                            return 'LE'
"gt"                            return 'GT'
"ge"                            return 'GE'
"doc"                            return 'DOC'
"for"                          return 'FOR'
"in"                           return 'IN'
"return"                   return 'RETURN'
"at"                           return 'AT'
"in"                           return 'IN'
"to"                           return 'TO'
"let"                         return 'LET'
"where"                  return 'WHERE'
"order"                   return 'ORDER'
"by"                         return 'BY'
"if"                            return 'IF'
"then"                      return 'THEN'
"else"                       return 'ELSE'
"data"                       return 'DATA'
"upper-case"          return 'UPPERCASE'
"substring"              return "SUBSTRING"

([a-zA-Z_])[a-zA-Z0-9_ñÑ.]*	return 'ID';
('$')([a-zA-Z_])[a-zA-Z0-9_ñÑ.]*	return 'VARIABLE';
<<EOF>>		                return 'EOF'

/lex
%left 'OR'
%left 'AND'
%left '=', '!='
%left '>=', '<=', '<', '>'
%left EQ,NE
%left LT,LE,GT,GE
%left '+' '-'
%left '*' 'DIV' 'MOD'


%start Init

%%

Init : LExpresiones EOF ;

LExpresiones : LExpresiones  Expresiones
                       | Expresiones;

Expresiones : For
                     | Return
                     | Let
                     | Where
                     | OrderBy 
                     | If;
		

Exp : DIVSIGN Lexp
    | Lexp;


Lexp : Lexp ORSIGN DIVSIGN Syntfin		
     | Lexp DIVSIGN Syntfin
     | Syntfin;


Syntfin    :  Fin
           | '@' Valor Opc
           |  Preservada '::' Fin
           | '@' Preservada Opc
	   | '@' '*';


Fin :  Valor Opc   
	| DIR Opc
    | TEXT   '('   ')'
    | NODE  '('   ')'
    | POSITION '('   ')'
    | LAST '('   ')'
    | DOC '(' STRING ')'
    | DATA'(' ExprLogica ')'
    | UPPERCASE'(' ExprLogica ')'
    | SUBSTRING '(' ExprLogica ',' ExprLogica ',' ExprLogica ')'
    | Preservada Opc 
    |'*' Opc ;



Valor : ID
      | NUMBER
      | STRING
      | STRING2
      | DECIMAL
      | VARIABLE;


Preservada:  CHILD
          | DESCENDANT
          | ANCESTOR
          | PRECEDING
          | FOLLOWING
	  | NAMESPACE
          | SELF
          | PARENT
          | ATTR;


Opc : '['ExprLogica ']'
        | ;


If: IF '(' ExprLogica ')' THEN Exp Else;

Else : ELSE Exp
       |;

For: FOR  LFor ;

LFor:LFor ','  VARIABLE IN ClauseExpr
       | LFor ',' VARIABLE AT VARIABLE IN  ClauseExpr
       | VARIABLE IN ClauseExpr
       | VARIABLE AT VARIABLE IN  ClauseExpr;

Let: LET VARIABLE ':=' ClauseExpr;

Where : WHERE ExprLogica;

OrderBy: ORDER BY LExp;

LExp : LExp ',' Exp
         | Exp;

ClauseExpr: ExprLogica
                    | '('ExprLogica TO ExprLogica')'
                    | '('ExprLogica',' ExprLogica')';

Return: RETURN ExprLogica
            | RETURN If;

ExprLogica
         : ExprLogica '<=' ExprLogica {
             $$ = new Relational($1, $3,RelationalOption.LESSOREQUAL ,@1.first_line, @1.first_column);
         }
         | ExprLogica '>=' ExprLogica {
            $$ = new Relational($1, $3,RelationalOption.GREATEROREQUAL ,@1.first_line, @1.first_column);
         }
         | ExprLogica '=' ExprLogica {
            $$ = new Relational($1, $3,RelationalOption.EQUAL ,@1.first_line, @1.first_column);
        }
         | ExprLogica '!=' ExprLogica  {
            $$ = new Relational($1, $3,RelationalOption.NOTEQUAL ,@1.first_line, @1.first_column);
        }
         | ExprLogica '>' ExprLogica {
            $$ = new Relational($1, $3,RelationalOption.GREATER ,@1.first_line, @1.first_column);
        }
         | ExprLogica '<' ExprLogica  {
            $$ = new Relational($1, $3,RelationalOption.LESS, @1.first_line, @1.first_column);
        }
         | ExprLogica 'EQ' ExprLogica 
         | ExprLogica 'NE' ExprLogica 
         | ExprLogica 'LT' ExprLogica 
         | ExprLogica 'LE' ExprLogica 
         | ExprLogica 'GT' ExprLogica 
         | ExprLogica 'GE' ExprLogica 
         | Expr;

Expr : Expr '+' Expr   
     | Expr '-' Expr
     | Expr '*' Expr
     | Expr DIV Expr
     | Expr  MOD Expr
     | Expr  OR Expr
     | Expr  AND Expr
     |'(' Expr ')'
     | Exp;
