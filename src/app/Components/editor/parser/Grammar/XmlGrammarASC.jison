 /*---------------------------IMPORTS-------------------------------*/
%{
    let valDeclaration = '';
    let valTag = '';
    let valInside = '';

    const {Error_} = require('../Error');
    const {errores} = require('../Errores');
    const {NodoXML} = require('../Nodes/NodoXml')
%}

/*----------------------------LEXICO-------------------------------*/
%lex
%options case-sensitive
%x xmloptions
%x tagval1
%x tagval2
%x valin

%%
"<?xml"                        %{ this.begin("xmloptions");%}
<xmloptions>"?>"               %{ 
                                    this.popState();
                                    console.log("xmloptions: "+valDeclaration);
                                    yytext = valDeclaration;
                                    valDeclaration = '';
                                    return 'tk_xmldec';
                               %}
<xmloptions>[^(\?>)]           %{ valDeclaration += yytext %}
<xmloptions><<EOF>>            %{ this.popState(); return 'EOF'; %}

["]                             %{ this.begin("tagval1"); %}   
<tagval1>["]                    %{ 
                                    this.popState(); 
                                    console.log("valtag: "+valTag); 
                                    yytext=valTag; valTag=""; 
                                    return 'tk_tagval';
                                %} 
<tagval1>"\\n"                  %{ valTag +='\n'; %}
<tagval1>"\\t"                  %{ valTag +='\t'; %}
<tagval1>"\\\\"                 %{ valTag +='\\'; %}
<tagval1>"\\r"                  %{ valTag +='\r'; %}
<tagval1>"\\\""                 %{ valTag +='\"'; %}
<tagval1>.                      %{ valTag += yytext; %}

[']                             %{ this.begin("tagval2"); %}   
<tagval2>[']                    %{ 
                                    this.popState(); 
                                    console.log("valtag: "+valTag); 
                                    yytext=valTag; valTag=""; 
                                    return 'tk_tagval';
                                %} 
<tagval2>"&lt;"                 %{ valTag +='<'; %}
<tagval2>"&gt;"                 %{ valTag +='>'; %}
<tagval2>"&amp;"                %{ valTag +='&'; %}
<tagval2>"&apos;"               %{ valTag +='\''; %}
<tagval2>"&quot;"               %{ valTag +='\"'; %}
<tagval2>.                      %{ valTag += yytext; %}

">"[^<]                         %{ this.begin("valin"); return 'tk_endtag';%}
<valin>"<"                      %{ 
                                    this.popState();
                                    console.log("value Inside: "+valInside);
                                    yytext = valInside;
                                    valInside = '';
                                    return 'tk_valin';
                                %}
<valin>[^<]                     %{ valInside += yytext; %}
<valin><<EOF>>                  %{ this.popState(); return 'EOF'; %}

">"                             %{ console.log(yytext); return 'tk_endtag'; %}
"<"                             %{ console.log(yytext); return 'tk_starttag'; %}
"/"                             %{ console.log(yytext); return 'tk_closetag'; %}                
"="                             %{ console.log(yytext); return 'tk_igual'; %}                                

[[a-zA-ZñÑáéíóúÁÉÍÓÚ]["_""-"0-9a-zA-ZñÑáéíóúÁÉÍÓÚ]*|["_""-"]+[0-9a-zA-ZñÑáéíóúÁÉÍÓÚ]["_""-"0-9a-zA-ZñÑáéíóúÁÉÍÓÚ]*] %{  console.log("id:"+yytext); return 'tk_id'; %}


[ \t\n\r\f] 		%{ /*se ignoran*/ %}
<<EOF>>             %{  return 'EOF';  %}

.                   %{ errores.push(new Error_(yylloc.first_line, yylloc.first_column, 'Lexico','Valor inesperado ' + yytext)); console.error(errores); %}


/lex
/*-------------------------SINTACTICO------------------------------*/
/*-----ASOCIACION Y PRECEDENCIA-----*/
/*----------ESTADO INICIAL----------*/
%start S
%% 
%locations
/*-------------GRAMATICA------------*/
S: tk_xmldec I EOF  { 
                        var s = new NodoXML("S","S",+yylineno+1,+@1.first_column+1,null);
                        var dec = new NodoXML("DEC","DEC",+yylineno+1,+@1.first_column+1,$1);
                        // s.addHijo(dec);
                        // s.addHijo($2);
                        return s;
                    }
|I EOF  { 
            var s = new NodoXML("S","S",+yylineno+1,+@1.first_column+1,null); 
            // s.addHijo($1);
            return s;
        }
;

I: OTAG CONTENIDO CTAG  {
                            var i = new NodoXML("I","I",+yylineno+1,+@1.first_column+1,null); 
                            i.addHijo($1);
                            i.addHijo($2);
                            i.addHijo($3);
                            $$ = i;
                        }
|OTAG CTAG  {
                var i = new NodoXML("I","I",+yylineno+1,+@1.first_column+1,null); 
                i.addHijo($1);
                i.addHijo($2);
                $$ = i;
            }
;

OTAG: tk_starttag tk_id tk_endtag   {
                                        $$ = tag = new NodoXML($1,'OTAG',+yylineno+1,+@1.first_column+1,null);
                                    }
|tk_starttag tk_id ARGUMENTOS tk_endtag {
                                            var tag = new NodoXML($1,'OTAG',+yylineno+1,+@1.first_column+1,null);
                                            tag.addHijo($1);
                                            $$ = tag;
                                        }
|tk_valin tk_id tk_endtag
|tk_valin tk_id ARGUMENTOS tk_endtag
;

ARGUMENTOS: ARGUMENTOS tk_id tk_igual tk_tagval
| tk_id tk_igual tk_tagval
;

CONTENIDO: CONTENIDO I  
| I
;

CTAG: tk_starttag tk_closetag tk_id tk_endtag
|tk_valin tk_closetag tk_id tk_endtag
;