import { NodoXML } from '../parser/Nodes/NodoXml';
import { EnvironmentXML } from '../parser/Symbol/EnviromentXML';
import { Error_ } from '../parser/Error';
import { errores } from '../parser/Errores';
import { XMLSymbol, TypeXml } from '../parser/Symbol/xmlSymbol';

export class EjecutorXML {
  entorno: EnvironmentXML;
  constructor() {
    this.entorno = new EnvironmentXML('global', null);
  }

  ejecutar(ast: NodoXML) {
    // console.log(ast);
    if (ast != null) {
      let tipo = ast.getTipo();
      console.log(tipo);
      switch (tipo) {
        case 'S':
          this.ejecutar(ast.getHijos()[0]);
          break;
        case 'I':
          this.ejecutarInicio(ast);
          break;
        case 'ARGS':
          ast.getHijos().forEach((element) => {
            this.ejecutar(element);
          });
          break;
        case 'ARG':
          this.ejecutarArg(ast);
          break;
        case 'CONTENT':
          console.log('ejecutando contenido');
          this.ejecutarContenido(ast);
          break;
        case 'VAl':
          console.log('agregando simbolo');
          this.ejecutarContenido(ast);
          break;
        default:
      }
    }
    return null;
  }

  private ejecutarInicio(ast: NodoXML) {
    if (ast != null) {
      if (ast.getHijos().length === 3) {
        // opening tag; contenido ; closing tag
        // opening tag; closing tag
        //verificar que la tag inicial sea el mismo id que la del final
        let nodos = ast.getHijos();
        // console.log(nodos);
        // console.log(nodos[0]);
        // console.log(nodos[1]);
        // console.log(nodos[2]);
        if (nodos[0].getID() === nodos[2].getID()) {
          // console.log('todo bien');
          //ejecutar opening tag
          this.ejecutarOtag(nodos[0], nodos[1]);
        } else {
          errores.push(
            new Error_(
              nodos[0].getLine(),
              nodos[0].getColumn(),
              'Semantico',
              `La Etiqueta de entrada => ${nodos[0].getID()} no es igual que la etiqueta de salida => ${nodos[2].getID()}`
            )
          );
        }
      } else if (ast.getHijos().length === 2) {
        let etiquetas = ast.getHijos();
        if (etiquetas[0].getID() === etiquetas[1].getID()) {
          this.ejecutarOtag(etiquetas[0], null);
        } else {
          errores.push(
            new Error_(
              etiquetas[0].getLine(),
              etiquetas[0].getColumn(),
              'Semantico',
              `La Etiqueta de entrada => ${etiquetas[0].getID()} no es igual que la etiqueta de salida => ${etiquetas[1].getID()}`
            )
          );
        }
      }
    }
  }

  private ejecutarOtag(etiqueta: NodoXML, contenido: NodoXML) {
    if (etiqueta != null && contenido != null) {
      //nuevo entorno
      console.log('nuevo env 1');
      let env = new EnvironmentXML(etiqueta.getID(), this.entorno);
      this.entorno = env;
      this.ejecutar(etiqueta.getHijos()[0]);
      this.ejecutar(contenido);
    } else if (etiqueta != null && contenido == null) {
      console.log('nuevo env 2');
      let env = new EnvironmentXML(etiqueta.getID(), this.entorno);
      this.entorno = env;
    }
  }

  private ejecutarArg(ast: NodoXML) {
    if (ast != null) {
      let id = ast.getID();
      let val = ast.getHijos()[0].getID();
      this.entorno.addSimbolo(
        new XMLSymbol(
          TypeXml.atributo,
          id,
          val,
          ast.getLine(),
          ast.getColumn(),
          this.entorno.nombre
        )
      );
    }
  }

  private ejecutarContenido(ast: NodoXML) {
    if (ast != null) {
      let hijos = ast.getHijos();
      switch (hijos.length) {
        case 4:
          // contenido; otag; contenido; ctag;
          this.ejecutarContenido(hijos[0]);
          this.ejecutarOtag(hijos[1], hijos[2]);
          break;
        case 3:
          // contenido; otag; ctag;
          // otag; contenido; ctag;
          if (hijos[0].getTipo() === 'CONTENT') {
            this.ejecutarContenido(hijos[0]);
            this.ejecutarOtag(hijos[1], null);
          } else {
            this.ejecutarOtag(hijos[0], hijos[1]);
          }
          break;
        case 2:
          // contenido; val;
          // otag; ctag;
          if (hijos[0].getTipo() === 'CONTENT') {
            this.ejecutarContenido(hijos[0]);
            var val = hijos[1].getID();
            this.entorno.addSimbolo(
              new XMLSymbol(
                TypeXml.valor,
                '',
                val,
                hijos[1].getLine(),
                hijos[1].getColumn(),
                this.entorno.nombre
              )
            );
          } else {
            this.ejecutarOtag(hijos[0], null);
          }
          break;
        case 1:
          // val;
          var val = hijos[0].getID();
          this.entorno.addSimbolo(
            new XMLSymbol(
              TypeXml.valor,
              '',
              val,
              hijos[0].getLine(),
              hijos[0].getColumn(),
              this.entorno.nombre
            )
          );
          break;
      }
    }
  }

  public getEntorno() {
    return this.entorno;
  }
}
