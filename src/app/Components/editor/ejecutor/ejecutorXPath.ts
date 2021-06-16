import { NodoXML } from '../parser/Nodes/NodoXml';
import { EnvironmentXPath } from '../parser/Symbol/EnviromentXPath';
import { EnvironmentXML } from '../parser/Symbol/EnviromentXML';
import { Error_ } from '../parser/Error';
import { errores } from '../parser/Errores';
import { _Console } from '../parser/Util/Salida';

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
          let find = this.ejecutarFin(ast);
          if(find) {
            let valor = this.environmentXML.getValor(this.environmentXML.nombre);
            _Console.salida = valor;
          }
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
    if(hijos.length == 0) return true;
    // console.log("hijos", hijos);
    let ruta = hijos[0].name;
      let nodes = this.environmentXML.hijos;
      let find = false;
      nodes.forEach(element => {
        if(element.nombre == ruta){
          // avanza un nivel
          this.environmentXML = element;
          find = true;
        }
      });
      if(!find){
        errores.push(
          new Error_(
            hijos[0].getLine(),
            hijos[0].getColumn(),
            'Semantico',
            `No se encuentra $ruta`
          )
          );
          return false;
      } 
      this.nivel++;
      this.ejecutarFin(hijos[0]);
      return true;
  }

  public getEntorno() {
    return this.entorno;
  }
}
