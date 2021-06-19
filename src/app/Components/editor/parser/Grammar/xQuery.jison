 /*---------------------------IMPORTS-------------------------------*/
%{
    let valDeclaration = '';
    let valTag = '';
    let valInside = '';
    const {Error_} = require('../Error');
    const {errores} = require('../Errores');
    const {NodoXML} = require('../Nodes/NodoXml')
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

([a-zA-Z_])[a-zA-Z0-9_ñÑ.]*	return 'ID';
('$')([a-zA-Z_])[a-zA-Z0-9_ñÑ.]*	return 'VARIABLE';
<<EOF>>		                return 'EOF'

/lex
%left 'OR'
%left 'AND'
%left '=', '!='
%left '>=', '<=', '<', '>'
%left '+' '-'
%left '*' 'DIV' 'MOD'


%start Init

%%

Init : Expresiones EOF ;

Expresiones : ExprLogica
                     | For
                     | Return;
		

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
    | Preservada Opc 
    |'*' Opc ;



Valor : ID
      | NUMBER
      | STRING
      | STRING2
      | DECIMAL;


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

For: FOR VARIABLE IN Exp;

Return: RETURN ExprLogica;

ExprLogica
         : Expr '<=' Expr
         | Expr '>=' Expr   
         | Expr '=' Expr   
         | Expr '!=' Expr  
         | Expr '>' Expr
         | Expr '<' Expr
         | Expr 'EQ' Expr
         | Expr 'NE' Expr   
         | Expr 'LT' Expr   
         | Expr 'LE' Expr  
         | Expr 'GT' Expr
         | Expr 'GE' Expr
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
