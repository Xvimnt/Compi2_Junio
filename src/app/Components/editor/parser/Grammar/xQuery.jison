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
    const {Arithmetic, ArithmeticOption} = require('../Expression/Arithmetic');
    const {Logic, LogicOption} = require('../Expression/Logic');
    const {Literal} = require('../Expression/Literal');
    // Instrucciones
    const {If} = require('../Instruction/If');
    const {ForIn} = require('../Instruction/ForIn');

    // Extra
    const {Type} = require('../Abstract/Retorno');
    
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

Init : LExpresiones EOF {
        return $1;
    }  
; 

LExpresiones : LExpresiones  Instrucciones {
        $1.push($2);
        $$ = $1;
    }
    | Instrucciones {
        $$ = [$1];
    }
;

Instrucciones : For { $$ = $1 }
                     | Return { $$ = $1 }
                     | Let { $$ = $1 }
                     | Where { $$ = $1 }
                     | OrderBy { $$ = $1 } 
                     | If { $$ = $1 };
		

Exp : DIVSIGN Lexp {
        $1.push($2);
        $$ = $1;
    }
    | Lexp { $$ = [$1] };


Lexp : Lexp ORSIGN DIVSIGN Syntfin		
     | Lexp DIVSIGN Syntfin
     | Syntfin { $$ = [$1] };


Syntfin    :  Fin { $$ = $1 }
           | '@' Valor Opc
           |  Preservada '::' Fin
           | '@' Preservada Opc
	   | '@' '*';


Fin :  Valor Opc  { $$ = $1 } 
	| DIR Opc { $$ = $1 } 
    | TEXT   '('   ')'
    | NODE  '('   ')'
    | POSITION '('   ')'
    | LAST '('   ')'
    | DOC '(' STRING ')'
    | DATA'(' ExprLogica ')'
    | UPPERCASE'(' ExprLogica ')'
    | SUBSTRING '(' ExprLogica ',' ExprLogica ',' ExprLogica ')'
    | Preservada Opc 
    | '*' Opc ;


    // enum Type {
    //     NUMBER = 0,
    //     STRING = 1,
    //     BOOLEAN = 2,
    //     NULL = 3,
    //     ARRAY = 4,
    //     RESERVADA = 5,
    //     TEMPLATE = 6,
    //     STRUCT = 7,
    //     FUNCION = 8,
    //     FLOAT = 9
    // }   
Valor : ID
      | NUMBER {
          $$ = new Literal($1, @1.first_line, @1.first_column, Type.NUMBER);
      }
      | STRING {
          $$ = new Literal($1, @1.first_line, @1.first_column, Type.STRING);
      }
      | STRING2 {
          $$ = new Literal($1, @1.first_line, @1.first_column,  Type.STRING);
      }
      | DECIMAL {
          $$ = new Literal($1, @1.first_line, @1.first_column,  Type.FLOAT);
      }
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


Opc : '['ExprLogica ']' { $$ = $1 } 
        | ;


If: IF '(' ExprLogica ')' THEN Exp Else {
     $$ = new If($3, $6, $7, @1.first_line, @1.first_column);
};

Else : ELSE Exp  { $$ = $2 }
       |;

For: FOR  LFor {$$ = $2};

LFor:LFor ','  VARIABLE IN ClauseExpr 
       | LFor ',' VARIABLE AT VARIABLE IN  ClauseExpr
       | VARIABLE IN ClauseExpr {
    $$ = new ForIn($1, $3, @1.first_line, @1.first_column);
}
       | VARIABLE AT VARIABLE IN  ClauseExpr;

Let: LET VARIABLE ':=' ClauseExpr;

Where : WHERE ExprLogica { $$ = $2 };

OrderBy: ORDER BY LExp { $$ = $3 };

LExp : LExp ',' Exp {
        $1.push($3);
        $$ = $1;
    }
         | Exp {$$ = [$1] };

ClauseExpr: ExprLogica {$$ = $1}
                    | '(' ExprLogica TO ExprLogica ')'
                    | '(' ExprLogica ',' ExprLogica ')';

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
         | ExprLogica 'EQ' ExprLogica {
            $$ = new Relational($1, $3,RelationalOption.EQUAL ,@1.first_line, @1.first_column);
        }
         | ExprLogica 'NE' ExprLogica  {
            $$ = new Relational($1, $3,RelationalOption.NOTEQUAL ,@1.first_line, @1.first_column);
        }
         | ExprLogica 'LT' ExprLogica  {
            $$ = new Relational($1, $3,RelationalOption.LESS, @1.first_line, @1.first_column);
        }
         | ExprLogica 'LE' ExprLogica {
             $$ = new Relational($1, $3,RelationalOption.LESSOREQUAL ,@1.first_line, @1.first_column);
         }
         | ExprLogica 'GT' ExprLogica {
            $$ = new Relational($1, $3,RelationalOption.GREATER ,@1.first_line, @1.first_column);
        }
         | ExprLogica 'GE' ExprLogica  {
            $$ = new Relational($1, $3,RelationalOption.GREATEROREQUAL ,@1.first_line, @1.first_column);
         }
         | Expr {$$ = $1};

Expr : Expr '+' Expr {
        $$ = new Arithmetic($1, $3, ArithmeticOption.PLUS, @1.first_line,@1.first_column);
    }  
     | Expr '-' Expr {
        $$ = new Arithmetic($1, $3, ArithmeticOption.MINUS, @1.first_line,@1.first_column);
    }
     | Expr '*' Expr { 
        $$ = new Arithmetic($1, $3, ArithmeticOption.TIMES, @1.first_line,@1.first_column);
    }  
     | Expr DIV Expr {
        $$ = new Arithmetic($1, $3, ArithmeticOption.DIV, @1.first_line,@1.first_column);
    }
     | Expr MOD Expr {
        $$ = new Arithmetic($1, $3, ArithmeticOption.MOD, @1.first_line,@1.first_column);
    }
     | Expr OR Expr {
        $$ = new Logic($1, $3,LogicOption.OR ,@1.first_line, @1.first_column);
    }
     | Expr AND Expr {
        $$ = new Logic($1, $3,LogicOption.AND ,@1.first_line, @1.first_column);
    }
     |'(' Expr ')' { $$ = $2 }
     | Exp { $$ = $1 };
