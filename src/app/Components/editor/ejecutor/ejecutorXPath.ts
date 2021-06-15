import { NodoXML } from '../parser/Nodes/NodoXml';
import { EnvironmentXPath } from '../parser/Symbol/EnviromentXPath';
import { EnvironmentXML } from '../parser/Symbol/EnviromentXML';
import { Error_ } from '../parser/Error';
import { errores } from '../parser/Errores';

export class EjecutorXPath {
  entorno: EnvironmentXPath;
  environmentXML: EnvironmentXML;
  constructor(xmlEnvironment: EnvironmentXML) {
    this.entorno = new EnvironmentXPath('global', null);
    this.environmentXML = xmlEnvironment; // El entorno de xml donde busca la consulta
  }

  ejecutar(ast: NodoXML) {
    // console.log(ast);
    if (ast != null) {
      let tipo = ast.getTipo();
      // console.log(tipo);
      switch (tipo) {
        case 'S':
          this.ejecutar(ast.getHijos()[0]);
          break;
        case 'I':
          this.ejecutarInicio(ast);
          break;
        // case 'OTAG':
        //   this.ejecutarOtag(ast, entorno);
        //   break;
        default:
      }
    }
    return null;
  }

  private ejecutarInicio(ast: NodoXML) {
    // opening tag; contenido ; closing tag
    // opening tag; closing tag
    //verificar que la tag inicial sea el mismo id que la del final
    let nodos = ast.getHijos();
    console.log(nodos);
    console.log(nodos[0]);
    console.log(nodos[1]);
    console.log(nodos[2]);
    if (nodos[0].getID() === nodos[2].getID()) {
      console.log('todo bien');
      //ejecutar opening tag
      this.ejecutarOtag(nodos[0], nodos[1]);
      //ejecutar content
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
    //ejecutar opening tag
    //ejecutar contenido
  }

  private ejecutarOtag(etiqueta: NodoXML, contenido: NodoXML) {
    //nuevo entorno
    console.log('nuevo env');
    let env = new EnvironmentXPath(etiqueta.getID(), this.entorno);
    this.entorno = env;
    // ejecutarAtributos(etiqueta.getHijos()[0], env);
    // ejecutarContenido(contenido,env);
  }

  public getEntorno() {
    return this.entorno;
  }
}
