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
  indexCount: number;
  constructor(xmlEnvironment: EnvironmentXML) {
    this.entorno = new EnvironmentXPath('global', null);
    this.nivel = 0;
    this.indexCount = 0;
    this.environmentXML = xmlEnvironment; // El entorno de xml donde busca la consulta
  }

  ejecutar(ast: NodoXML) {
    // console.log("nodo pricipal xpath",ast);
    let response = null;
    if (ast != null) {
      let tipo = ast.getTipo();
      // console.log("tipo",tipo);
      switch (tipo) {
        case 'Fin':
          let find = this.ejecutarFin(ast);
          if (find) {
            // console.log("entorno",this.environmentXML);
            let valor = this.environmentXML.getValor(this.environmentXML.nombre);
            _Console.salida = valor;
          }
          break;
        case 'LPredicado':
          let index = this.ejecutarPredicado(ast);
          return index;
        default:
          let nodos = ast.getHijos();
          nodos.forEach(element => {
            response = this.ejecutar(element);
          });
          break;
      }
    }
    return response;
  }

  ejecutarPredicado(ast: NodoXML): string {
    let result = "";
    if (ast != null) {
      let tipo = ast.getTipo();
      // console.log("tipo",tipo);
      switch (tipo) {
        case 'Fin':
          let hijos = ast.getHijos();
          let index = hijos[0].name;
          return index;
        default:
          let nodos = ast.getHijos();
          nodos.forEach(element => {
            let retorno = this.ejecutarPredicado(element);
            result = (retorno == "") ? result : retorno;
          });
          break;
      }
    }
    return result;
  }

  ejecutarFin(ast: NodoXML) {
    let hijos = ast.getHijos();
    // console.log("hijos", hijos);
    if (hijos.length == 0) return true;
    let ruta = hijos[0].name;
    // console.log("validando",this.environmentXML,hijos[0]);
    let nodes = this.environmentXML.hijos;
    let find = false;
    nodes.forEach(element => {
      // console.log("validando",element.nombre,ruta);
      if (element.nombre == ruta) {
        // valida si tiene index
        if (hijos[1].listaNodos.length != 0) {
          let index = this.ejecutar(hijos[1]);
          if (index == this.indexCount) {
            console.log("element",element);
            // avanza un nivel
            this.environmentXML = element;
            find = true;
            this.indexCount = 0;
          }
          this.indexCount++;
        }
        else {
          // avanza un nivel
          this.environmentXML = element;
          find = true;
        }
      }
    });
    if (!find) {
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

    return this.ejecutarFin(hijos[0]);
  }

  public getEntorno() {
    return this.entorno;
  }
}
