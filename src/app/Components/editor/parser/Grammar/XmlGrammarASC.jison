 /*---------------------------IMPORTS-------------------------------*/
%{
    let valDeclaration = '';
%}

/*----------------------------LEXICO-------------------------------*/
%lex
%options case-sensitive
%x xmloptions
%x tag

%%
"<?xml"                        %{ this.begin("xmloptions");%}
<xmloptions>"?>"               %{ 
                                    this.popState();
                                    yytext = valDeclaration;
                                    valDeclaration = '';
                                    return 'tk_xmldec';
                               %}
<xmloptions>[^(\?>)]           %{ valDeclaration += yytext %}
<xmloptions><<EOF>>            %{ this.popState(); return 'EOF'; %}

"<"                            %{this.begin("tag"); console.log(`tk_openingtag -> ${yytext}`); return 'tk_openingtag'; %}
<tag>">"                       %{this.popState(); console.log(`tk_closingtag -> ${yytext}`); return 'tk_closingtag'; %}
<tag>[[a-zA-ZñÑáéíóúÁÉÍÓÚ]["_""-"0-9a-zA-ZñÑáéíóúÁÉÍÓÚ]*|["_""-"]+[0-9a-zA-ZñÑáéíóúÁÉÍÓÚ]["_""-"0-9a-zA-ZñÑáéíóúÁÉÍÓÚ]*] %{  console.log("tag id:"+yytext); return 'tk_tag_id'; %}
<tag>"/"                       %{ console.log(`tk_slash -> ${yytext}`); return 'tk_slash'; %}
<tag>[^>]                      %{ %}


[ \t\n\r\f] 		%{ /*se ignoran*/ %}
<<EOF>>             %{  return 'EOF';  %}

.                   %{ /*errores.push(new Error_(yylloc.first_line, yylloc.first_column, 'Lexico','Valor inesperado ' + yytext));*/ console.error(`Error Lexico -> ${yytext}`) %}


/lex
/*-------------------------SINTACTICO------------------------------*/
/*-----ASOCIACION Y PRECEDENCIA-----*/
/*----------ESTADO INICIAL----------*/
%start S
%% 
%locations
/*-------------GRAMATICA------------*/
S: tk_xmldec EOF
 | tk_id EOF
 | tk_openingtag tk_tag_id tk_closingtag EOF
 | EOF;