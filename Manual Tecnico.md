# Grupo 18 
# Manual Tecnico

## Tecnologias Usadas:
### Code Mirror:
https://codemirror.net/
Un editor de texto construido en javascript, que se utilizó para mostrar el código en la interfaz.

### Viz js:
https://github.com/mdaines/viz.js/
Librería que se utilizó para graficar los árboles en el proyecto.

### Angular:
https://angular.io/
Framework que se utilizó para realizar el proyecto

### Gh pages:
https://tytusdb.github.io/tytusx/20211SVAC/G18/ 
tecnología de github para mostrar páginas estáticas, se utilizo para mostrar el proyecto en la web. 

### Bootstrap:
https://getbootstrap.com/
Librería que se utilizó para agregar estilo a la interfaz del proyecto.

### Font Awesome:
https://fontawesome.com/
Librería que se utilizó para agregar iconos a la interfaz.

## Gramatica Ascendente para XML
``` jison
S: tk_xmldec I EOF  
|I EOF  
| EOF   
;
 
I:OTAG CONTENIDO CTAG
|OTAG CTAG  
;
 
OTAG: tk_starttag tk_id tk_endtag   
|tk_starttag tk_id ARGUMENTOS tk_endtag             
;
 
ARGUMENTOS: ARGUMENTOS tk_id tk_igual tk_tagval 
| tk_id tk_igual tk_tagval    
;
 
CONTENIDO: CONTENIDO OTAG CONTENIDO CTAG
| CONTENIDO OTAG CTAG   
| CONTENIDO SIMPLETAG2  
| CONTENIDO tk_valin
| OTAG CONTENIDO CTAG   
| OTAG CTAG 
| SIMPLETAG2
| tk_valin 
;
 
SIMPLETAG2: tk_starttag tk_id ARGUMENTOS tk_closetag tk_endtag 
       | tk_starttag tk_id tk_closetag tk_endtag  
       ;
 
CTAG: tk_starttag tk_closetag tk_id tk_endtag;
```
## Gramatica descendente para XML
```
S: tk_xmldec I EOF  
|I EOF  
| EOF   
;
 
I: OTAG LELEMENT CTAG;
 
LELEMENT: OTAG LELEMENT CTAG LELEMENT  
       | tk_valin LELEMENT 
       | epsilon    
       ;
 
OTAG: tk_starttag tk_id tk_endtag   
|tk_starttag tk_id ARGUMENTOS tk_endtag 
;
 
ARGUMENTOS: tk_id tk_igual tk_tagval ARGUMENTOSP ;
 
ARGUMENTOSP: tk_id tk_igual tk_tagval ARGUMENTOSP 
         | epsilon
         ;
 
CTAG: tk_closetag tk_id tk_endtag;
```