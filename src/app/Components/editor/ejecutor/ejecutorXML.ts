import { NodoXML } from '../parser/Nodes/NodoXml';
import { EnvironmentXML } from '../parser/Symbol/EnviromentXML';

export class EjecutarXML {
  public ast: NodoXML;
  public entorno: EnvironmentXML;

  constructor(ast, entorno) {
    this.ast = ast;
    this.entorno = entorno;
  }

  ejecutar(ast, entorno) {
    if (ast != null) {
      let tipo = ast.getTipo();
      console.log(tipo);
      switch (tipo) {
        case 'S':
          this.ejecutar(ast.getListaNodos()[0], entorno);
        case 'I':
          ast.getListaNodos().forEach((element) => {
            this.ejecutar(element, entorno);
          });
      }
    }
    return null;
  }
}
