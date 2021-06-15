import { NodoXML } from '../parser/Nodes/NodoXml';
import { EnvironmentXPath } from '../parser/Symbol/EnviromentXPath';
import { EnvironmentXML } from '../parser/Symbol/EnviromentXML';
import { Error_ } from '../parser/Error';
import { errores } from '../parser/Errores';

export class EjecutorXPath {
  entorno: EnvironmentXPath;
  environmentXML: EnvironmentXML;
  nivel: number;

  constructor(xmlEnvironment: EnvironmentXML) {
    this.entorno = new EnvironmentXPath('global', null);
    this.nivel = 0;
    this.environmentXML = xmlEnvironment; // El entorno de xml donde busca la consulta
  }

  ejecutar(ast: NodoXML) {
    // console.log("nodo pricipal xpath",ast);
    if (ast != null) {
      let tipo = ast.getTipo();
      // console.log("tipo",tipo);
      switch (tipo) {
        case 'Fin':
          this.ejecutarFin(ast);
          break;
        // case 'OTAG':
        //   this.ejecutarOtag(ast, entorno);
        //   break;
        default:
          let nodos = ast.getHijos();
          nodos.forEach(element => {
            this.ejecutar(element);
          });
          break;
      }
    }
    return null;
  }

  ejecutarFin(ast: NodoXML){
    let hijos = ast.getHijos();
    let ruta = hijos[0].name;
    console.log("ruta",ruta,"nivel",this.nivel);
    console.log("entorno xml",this.environmentXML);
    this.nivel++;
  }

  public getEntorno() {
    return this.entorno;
  }
}
