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
    const {Access} = require('../Expression/Access');
    const {Variable} = require('../Expression/Variable');
    // Instrucciones
    const {If} = require('../Instruction/If');
    const {ForIn} = require('../Instruction/ForIn');
    const {Function} = require('../Instruction/Function');
    const {Call} = require('../Instruction/Call');
    const {Statement} = require('../Instruction/Statement');

    // Extra
    const {Type} = require('../Abstract/Retorno');
    
%}

%lex
%options case-sensitive
%x comment1
%x comment2

number      [0-9]+
divsign     ('/')('/')?
dir         ('.')('.')?
orsign      ('|')('|')?
decimal     [0-9]+("."[0-9]+)?
string      ([\"][^"]*[\"])
string2     ([\'][^\']*[\'])

ancestor    ('ancestor')('-or-self')?
following   ('following')('-sibling')?
preceding   ('preceding')('-sibling')?

%%
"<!--"							%{ this.begin("comment1"); %}
<comment1>"-->"		  	        %{ this.popState(); %}
<comment1>.				        %{ %}
<comment1>[ \t\r\n\f]	        %{ %}

"(:"							%{ this.begin("comment2"); %}
<comment2>":)"		  	        %{ this.popState(); %}
<comment2>.				        %{ %}
<comment2>[ \t\r\n\f]	        %{ %}

[ \t\n\r\f] 		        %{ /*se ignoran*/ %}

{decimal}                   return 'DECIMAL'
{number}                    return 'NUMBER'
{string}                    return 'STRING'
{string2}                   return 'STRING2'
{divsign}                   return 'DIVSIGN'
{dir}                       return 'DIR'
{ancestor}                  return 'ANCESTOR'
{following}                 return 'FOLLOWING'
{preceding}                 return 'PRECEDING'
{orsign}                    return 'ORSIGN'

"@"                         return '@'
"*"                         return '*'
"::"                        return '::'
":="                        return ':='
"-"                         return '-'
"+"                         return '+'
","                         return ','
":"                         return ':'
";"                         return ';'

"</"                        return '</'
"<="                        return '<='
">="                        return '>='
"<"                         return '<'
">"                         return '>'
"!="                        return '!='
"="                         return '='
"or"                        return 'OR'
"and"                       return 'AND'
"mod"                       return 'MOD'
"div"                       return 'DIV'

"("                         return '('
")"                         return ')' 
"["                         return '['
"]"                         return ']'
"{"                         return 'tk_llavea'
"}"                         return 'tk_llavec'

"child"                     return 'CHILD'
"attribute"                 return 'ATTR'
"descendant"                return 'DESCENDANT'
"namespace"                 return 'NAMESPACE'
"parent"                    return 'PARENT'
'self'                      return 'SELF'
"text"                      return 'TEXT'
"last"                      return 'LAST'
"position"                  return 'POSITION'
"node"                      return 'NODE'
"eq"                        return 'EQ'
"ne"                        return 'NE'
"lt"                        return 'LT'
"le"                        return 'LE'
"gt"                        return 'GT'
"ge"                        return 'GE'
"doc"                       return 'DOC'
"for"                       return 'FOR'
"in"                        return 'IN'
"return"                    return 'RETURN'
"at"                        return 'AT'
"in"                        return 'IN'
"to"                        return 'TO'
"let"                       return 'LET'
"where"                     return 'WHERE'
"order"                     return 'ORDER'
"by"                        return 'BY'
"if"                        return 'IF'
"then"                      return 'THEN'
"else"                      return 'ELSE'
"data"                      return 'DATA'
"upper-case"                return 'UPPERCASE'
"substring"                 return "SUBSTRING"


"declare"                   return 'DECLARE'
"function"                 return 'FUNCTION'
"local"                       return 'LOCAL'
"as"                            return 'AS'
"xs"                            return 'XS'
"decimal"                  return 'DECIMAL_'
"integer"                   return 'INTEGER_'
"string"                     return 'STRING_'
"date"                        return 'DATE_'
"time"                       return 'TIME_'
"dateTime"               return 'DATETIME_'
"boolean"                 return 'BOOLEAN_'
"double"                   return 'DOUBLE_'
"float"                       return 'FLOAT_'



([a-zA-Z_])[a-zA-Z0-9_ñÑ.]*	        return 'ID';
('$')([a-zA-Z_])[a-zA-Z0-9_ñÑ.]*	return 'VARIABLE';
<<EOF>>		                        return 'EOF'

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
				$$ = [$1] 
			}
    | HTML 
	| error {        
			errores.push(new Error_(@1.first_line, @1.first_column, 'Sintactico','Valor inesperado ' + yytext));
			return "error";
		}
;

Instrucciones : For { 
						$$ = $1; 
			}
                     | Return  { 
						$$ = $1; 
			}
                     | Let     { 
						$$ = $1; 
			}
                     | If      { 
						$$ = $1; 
			}
                     | Valor   { 
						$$ = $1; 
			}
                     |Function { 
						$$ = $1; 
			}
                     ;
		
LlamadaFuncion: LOCAL ':' ID '(' LParams ')'{					
			$$ = new Call($3,$5,@1.first_line+1,@1.first_column+1);
		}
              | LOCAL ':' ID '(' ')'{					
					$$ = new Call($3,null,@1.first_line+1,@1.first_column+1);
		};

LParams : LParams ',' ExprLogica {	
			$1.push($3);
			$$ = $1;
		}
		| ExprLogica {		
			$$ = [$1];
		};

Exp : DIVSIGN Lexp {					
			$$ = $2;
		}
    | Lexp {			
			$$ = $1;
		};


Lexp : Lexp ORSIGN DIVSIGN Syntfin	{
			var lexp = new NodoXML("Lexp","Lexp",@1.first_line+1,@1.first_column+1);
			var val1 = new NodoXML($2,"Lexp",@1.first_line+1,@1.first_column+1);
			var val2 = new NodoXML($3,"Lexp",@1.first_line+1,@1.first_column+1);
			lexp.addHijo($1);
			lexp.addHijo(val1);
			lexp.addHijo(val2);
			lexp.addHijo($4);
			$$ = lexp;
		}	
     | Lexp DIVSIGN Syntfin{						
			var lexp = new NodoXML("Lexp","Lexp",@1.first_line+1,@1.first_column+1);
			var val1 = new NodoXML($2,"Lexp",@1.first_line+1,@1.first_column+1);			
			lexp.addHijo($1);
			lexp.addHijo(val1);			
			lexp.addHijo($3);
			$$ = lexp;
		}
     | Syntfin {
			$$ = $1;
		};


Syntfin    :  Fin {
					$$ = $1;
				}
           | '@' Valor Opc{
					var syntfin = new NodoXML("Syntfin","Syntfin",@1.first_line+1,@1.first_column+1);
					var val1 = new NodoXML($1,"Syntfin",@1.first_line+1,@1.first_column+1);								
					syntfin.addHijo(val1);
					syntfin.addHijo($2);			
					syntfin.addHijo($3);										
					$$ = syntfin;
				}
           |  Preservada '::' Fin{
					var syntfin = new NodoXML("Syntfin","Syntfin",@1.first_line+1,@1.first_column+1);
					var val1 = new NodoXML($2,"Syntfin",@1.first_line+1,@1.first_column+1);													
					syntfin.addHijo($1);			
					syntfin.addHijo(val1);
					syntfin.addHijo($3);										
					$$ = syntfin;
				}
           | '@' Preservada Opc {
					var syntfin = new NodoXML("Syntfin","Syntfin",@1.first_line+1,@1.first_column+1);
					var val1 = new NodoXML($1,"Syntfin",@1.first_line+1,@1.first_column+1);								
					syntfin.addHijo(val1);
					syntfin.addHijo($2);			
					syntfin.addHijo($3);										
					$$ = syntfin;
				}
	   | '@' '*' {
	   
					var syntfin = new NodoXML("Syntfin","Syntfin",@1.first_line+1,@1.first_column+1);
					var val1 = new NodoXML($1,"Syntfin",@1.first_line+1,@1.first_column+1);								
					var val2 = new NodoXML($2,"Syntfin",@1.first_line+1,@1.first_column+1);								
					syntfin.addHijo(val1);
					syntfin.addHijo(val2);					
					$$ = syntfin;
				};


Fin :  Valor Opc  { 
			$$ = $1;
		}
	| DIR Opc { 
	var fin = new NodoXML("Fin","Fin",@1.first_line+1,@1.first_column+1);
			var val1 = new NodoXML($1,"Fin",@1.first_line+1,@1.first_column+1);								
			fin.addHijo(val1);		
			fin.addHijo($2);					
			$$ = fin;
		}
    | TEXT   '('   ')'{
				var fin = new NodoXML("Fin","Fin",@1.first_line+1,@1.first_column+1);
			var val1 = new NodoXML($1,"Funcion",@1.first_line+1,@1.first_column+1);								
			fin.addHijo(val1);									
			$$ = fin;
		}
    | NODE  '('   ')'{		
			var fin = new NodoXML("Fin","Fin",@1.first_line+1,@1.first_column+1);
			var val1 = new NodoXML($1,"Funcion",@1.first_line+1,@1.first_column+1);								
			fin.addHijo(val1);									
			$$ = fin;
		}
    | POSITION '('   ')'{
			var fin = new NodoXML("Fin","Fin",@1.first_line+1,@1.first_column+1);
			var val1 = new NodoXML($1,"Funcion",@1.first_line+1,@1.first_column+1);								
			fin.addHijo(val1);									
			$$ = fin;
		}
    | LAST '('   ')'{
			var fin = new NodoXML("Fin","Fin",@1.first_line+1,@1.first_column+1);
			var val1 = new NodoXML($1,"Funcion",@1.first_line+1,@1.first_column+1);								
			fin.addHijo(val1);									
			$$ = fin;
		}
	
    | DOC '(' STRING ')' {
			var fin = new NodoXML("Fin","Fin",@1.first_line+1,@1.first_column+1);
			var val1 = new NodoXML($1,"Funcion",@1.first_line+1,@1.first_column+1);								
			var val2 = new NodoXML($3,"Funcion",@1.first_line+1,@1.first_column+1);								
			fin.addHijo(val1);	
			fin.addHijo(val2);				
			$$ = fin;
		}
    | DATA'(' ExprLogica ')' {
			var fin = new NodoXML("Fin","Fin",@1.first_line+1,@1.first_column+1);
			var val1 = new NodoXML($1,"Funcion",@1.first_line+1,@1.first_column+1);																
			fin.addHijo(val1);	
			fin.addHijo($3);				
			$$ = fin;
		}
    | UPPERCASE'(' ExprLogica ')'{
			var fin = new NodoXML("Fin","Fin",@1.first_line+1,@1.first_column+1);
			var val1 = new NodoXML($1,"Funcion",@1.first_line+1,@1.first_column+1);																
			fin.addHijo(val1);	
			fin.addHijo($3);				
			$$ = fin;
		}
    | SUBSTRING '(' ExprLogica ',' ExprLogica ',' ExprLogica ')'{
			var fin = new NodoXML("Fin","Fin",@1.first_line+1,@1.first_column+1);
			var val1 = new NodoXML($1,"Funcion",@1.first_line+1,@1.first_column+1);																
			fin.addHijo(val1);	
			fin.addHijo($3);	
			fin.addHijo($5);	
			fin.addHijo($7);	
			$$ = fin;
		}
    | Preservada Opc {
			var fin = new NodoXML("Fin","Fin",@1.first_line+1,@1.first_column+1);			
			fin.addHijo($1);
			fin.addHijo($2);												
			$$ = fin;
		}
    | '*' Opc {
			var fin = new NodoXML("Fin","Fin",@1.first_line+1,@1.first_column+1);
			var val1 = new NodoXML($1,"Fin",@1.first_line+1,@1.first_column+1);								
			fin.addHijo(val1);	
			fin.addHijo($2);				
			$$ = fin;
		};


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
Valor : ID {
		$$ = new Access($1, @1.first_line, @1.first_column);
	  }
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
      | VARIABLE{
          $$ = new Access($1, @1.first_line, @1.first_column);
      }
	  | LlamadaFuncion{
          $$ = $1;
      };


Preservada:  CHILD{
						var val = new NodoXML($1,"Axes",@1.first_line+1,@1.first_column+1);				
						$$ = val;
					}
          | DESCENDANT{
		  				var val = new NodoXML($1,"Axes",@1.first_line+1,@1.first_column+1);				
						$$ = val;
					}
          | ANCESTOR{
		  				var val = new NodoXML($1,"Axes",@1.first_line+1,@1.first_column+1);				
						$$ = val;
					}
          | PRECEDING{
		  				var val = new NodoXML($1,"Axes",@1.first_line+1,@1.first_column+1);				
						$$ = val;
					}
          | FOLLOWING{
		  				var val = new NodoXML($1,"Axes",@1.first_line+1,@1.first_column+1);				
						$$ = val;
					}
	      | NAMESPACE{
		  				var val = new NodoXML($1,"Axes",@1.first_line+1,@1.first_column+1);				
						$$ = val;
					}
          | SELF{
		  				var val = new NodoXML($1,"Axes",@1.first_line+1,@1.first_column+1);				
						$$ = val;
					}
          | PARENT{
		  				var val = new NodoXML($1,"Axes",@1.first_line+1,@1.first_column+1);				
						$$ = val;
					}
          | ATTR{
		  				var val = new NodoXML($1,"Axes",@1.first_line+1,@1.first_column+1);				
						$$ = val;
					};


Opc : '['ExprLogica ']' { 
				var predicado = new NodoXML("Opc","Opc",@1.first_line+1,@1.first_column+1);								
				predicado.addHijo($2);	
				$$ = predicado;
		} 
        | {
				var opc = new NodoXML("Opc","Opc",@1.first_line+1,@1.first_column+1);									
				$$ = opc;
		};



If: IF '(' ExprLogica ')' THEN stmnt ELSE  stmnt{
				$$ = new If($3, $6, $8 ,@1.first_line+1, @1.first_column+1);		
};

stmnt: '('')' {
			$$ = null;
		}
        | '('LExpresiones')'{
			$$ = $1;
		}
        | Instrucciones{
				$$ = $1;
		}
		;


For: FOR  LFor forstmnt LForWhere{
				$$ = new ForIn($1,$2,$3,@1.first_line+1,@1.first_column+1);
		};

LFor:LFor ','  VARIABLE IN ClauseExpr {
				var for_ = new NodoXML("ForExpr","ForExpr",@1.first_line+1,@1.first_column+1);								
				var val1 = new NodoXML($3,"Variable",@1.first_line+1,@1.first_column+1);			
				var val2 = new NodoXML($4,"IN",@1.first_line+1,@1.first_column+1);			
				for_.addHijo($1);					
				for_.addHijo(val1);
				for_.addHijo($5);
				$$ = for_;
		}
       | LFor ',' VARIABLE AT VARIABLE IN  ClauseExpr{
				var for_ = new NodoXML("ForExpr","ForExpr",@1.first_line+1,@1.first_column+1);								
				var val1 = new NodoXML($3,"Variable",@1.first_line+1,@1.first_column+1);	
				var val2 = new NodoXML($4,"AT",@1.first_line+1,@1.first_column+1);			
				var val3 = new NodoXML($5,"Variable",@1.first_line+1,@1.first_column+1);					
				var val4 = new NodoXML($6,"IN",@1.first_line+1,@1.first_column+1);	
				for_.addHijo($1);					
				for_.addHijo(val1);
				for_.addHijo(val2);
				for_.addHijo(val3);
				for_.addHijo(val4);
				for_.addHijo($7);
				$$ = for_;
		}
       | VARIABLE IN ClauseExpr {
			var for_ = new NodoXML("ForExpr","ForExpr",@1.first_line+1,@1.first_column+1);								
				var val1 = new NodoXML($1,"Variable",@1.first_line+1,@1.first_column+1);			
				var val2 = new NodoXML($2,"IN",@1.first_line+1,@1.first_column+1);			
				for_.addHijo($1);					
				for_.addHijo(val1);
				for_.addHijo($3);
				$$ = for_;
}
       | VARIABLE AT VARIABLE IN  ClauseExpr{
			var for_ = new NodoXML("ForExpr","ForExpr",@1.first_line+1,@1.first_column+1);								
				var val1 = new NodoXML($1,"Variable",@1.first_line+1,@1.first_column+1);	
				var val2 = new NodoXML($2,"AT",@1.first_line+1,@1.first_column+1);			
				var val3 = new NodoXML($3,"Variable",@1.first_line+1,@1.first_column+1);					
				var val4 = new NodoXML($4,"IN",@1.first_line+1,@1.first_column+1);									
				for_.addHijo(val1);
				for_.addHijo(val2);
				for_.addHijo(val3);
				for_.addHijo(val4);
				for_.addHijo($5);
				$$ = for_;
	   };

forstmnt : LForExpresiones{
			var for_ = new NodoXML("Stmnt","Stmnt",@1.first_line+1,@1.first_column+1);								
				for_.addHijo($1);
				$$ = for_;
	   }
                | {var for_ = new NodoXML("Stmnt","Stmnt",@1.first_line+1,@1.first_column+1);												
				$$ = for_;};

LForExpresiones: LForExpresiones For_Let_Opt{
		var for_ = new NodoXML("Stmnt","Stmnt",@1.first_line+1,@1.first_column+1);								
				for_.addHijo($1);
				for_.addHijo($2);
				$$ = for_;
}
                            | For_Let_Opt {
							
								var for_ = new NodoXML("Stmnt","Stmnt",@1.first_line+1,@1.first_column+1);								
				for_.addHijo($1);				
				$$ = for_;
							};

For_Let_Opt: Let {
			var for_ = new NodoXML("Stmnt","Stmnt",@1.first_line+1,@1.first_column+1);								
				for_.addHijo($1);				
				$$ = for_;
}
                      | For
					  {
							var for_ = new NodoXML("Stmnt","Stmnt",@1.first_line+1,@1.first_column+1);								
				for_.addHijo($1);				
				$$ = for_;
}
						
					  }
					  ;
	   
LForWhere:   Where LForOrderby { 
				var for_ = new NodoXML("Stmnt","Stmnt",@1.first_line+1,@1.first_column+1);								
				for_.addHijo($1);
				for_.addHijo($2);
				$$ = for_;
}
                     |LForOrderby{
							var for_ = new NodoXML("Stmnt","Stmnt",@1.first_line+1,@1.first_column+1);								
							for_.addHijo($1);				
							$$ = for_;
}
					 
					 ;

LForOrderby: Orderby  LForReturn { 
				var for_ = new NodoXML("Stmnt","Stmnt",@1.first_line+1,@1.first_column+1);								
				for_.addHijo($1);
				for_.addHijo($2);
				$$ = for_;
}
                               |LForReturn{
									var for_ = new NodoXML("Stmnt","Stmnt",@1.first_line+1,@1.first_column+1);								
				for_.addHijo($1);				
				$$ = for_;
								
							   };

LForReturn: Return {	var for_ = new NodoXML("Stmnt","Stmnt",@1.first_line+1,@1.first_column+1);								
				for_.addHijo($1);				
				$$ = for_;
};

Let: LET VARIABLE ':=' ClauseExpr  { 
				var let_ = new NodoXML("Let","Let",@1.first_line+1,@1.first_column+1);			
				var val1 = new NodoXML($2,"Variable",@1.first_line+1,@1.first_column+1);	
				let_.addHijo(val1);
				let_.addHijo($4);
				$$ = let_;
};

Where : WHERE ExprLogica  { 
				var where_ = new NodoXML("Where","Where",@1.first_line+1,@1.first_column+1);							
				where_.addHijo($2);
				$$ = where_;
};

OrderBy: ORDER BY LExp { 
				var OrderBy_ = new NodoXML("OrderBy","OrderBy",@1.first_line+1,@1.first_column+1);							
				OrderBy_.addHijo($3);
				$$ = OrderBy_;
};

LExp : LExp ',' Exp {
				var lexp = new NodoXML("LExp","LExp",@1.first_line+1,@1.first_column+1);							
				lexp.addHijo($1);
				lexp.addHijo($3);
				$$ = lexp;
}
         | Exp {
				var lexp = new NodoXML("LExp","LExp",@1.first_line+1,@1.first_column+1);							
				lexp.addHijo($1);
				$$ = lexp;
};

ClauseExpr: ExprLogica {
				var lexp = new NodoXML("ClauseExpr","ClauseExpr",@1.first_line+1,@1.first_column+1);							
				lexp.addHijo($1);
				$$ = lexp;
}
                    | '(' ExprLogica TO ExprLogica ')'
					{
				var lexp = new NodoXML("ClauseExpr","ClauseExpr",@1.first_line+1,@1.first_column+1);	
				var val1 = new NodoXML($3,"TO",@1.first_line+1,@1.first_column+1);				
				lexp.addHijo($2);
				lexp.addHijo(val1);
				lexp.addHijo($4);
				$$ = lexp;
}
                    | '(' ExprLogica ',' ExprLogica ')'{
				var lexp = new NodoXML("ClauseExpr","ClauseExpr",@1.first_line+1,@1.first_column+1);				
				lexp.addHijo($2);
				lexp.addHijo($4);
				$$ = lexp;
};

Return: RETURN ExprLogica{
				var lexp = new NodoXML("Return","Return",@1.first_line+1,@1.first_column+1);				
				lexp.addHijo($2);
				$$ = lexp;
}
        | RETURN If{
				var lexp = new NodoXML("Return","Return",@1.first_line+1,@1.first_column+1);				
				lexp.addHijo($2);
				$$ = lexp;
}
        | RETURN HTML{
				var lexp = new NodoXML("Return","Return",@1.first_line+1,@1.first_column+1);				
				lexp.addHijo($2);
				$$ = lexp;
}
        ;

Function : DECLARE FUNCTION Prefix ':' ID Parameter  AS XS':'TipoVar prod_statement ';'{
	$$ = new Function($5,$6,$10,$11,@1.first_line+1,@1.first_column+1);
};

prod_statement: tk_llavea LExpresiones tk_llavec {
	$$ = new Statement($2, @1.first_line, @1.first_column);
} | tk_llavea tk_llavec {
	$$ = new Statement([], @1.first_line, @1.first_column);
};

Parameter: '(' LVariables ')' {$$ = $2}
                  |'('')' {$$ = null};

LVariables: LVariables ',' VARIABLE AS XS':'TipoVar {
				$1.push(new Variable($3, $7, @1.first_line, @1.first_column));
				$$ = $1;
			}
                  | VARIABLE  AS XS ':' TipoVar {
					  $$ = [new Variable($1, $5, @1.first_line, @1.first_column)]
					}; 

TipoVar: INTEGER_
              | DECIMAL_
              | STRING_              
              | BOOLEAN_
              | DOUBLE_;

Prefix: LOCAL;

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
     |'(' ExprLogica ')' { $$ = $2 }
	 | Exp { $$ = $1 };

HTML: HTML HTMLSTRING
    | HTMLSTRING
    ;

HTMLSTRING: '<' ID ATRIBUTOS SUFIX
        | '<' ID SUFIX
        ;

ATRIBUTOS: ATRIBUTOS ID '=' STRING
         | ATRIBUTOS ID '=' STRING2
         | ATRIBUTOS ID '=' [\"] XQUERY [\"]
         | ID '=' STRING
         | ID '=' STRING2
         | ID '=' [\"] XQUERY [\"]
         ;
         
SUFIX: '/>'
    | '>' XQUERY '</' ID '>'
    | '>' HTML '</' ID '>'
    | '>' (ID|[.])* '</' ID '>' 
    ;

XQUERY: tk_llavea LExpresiones tk_llavec;
