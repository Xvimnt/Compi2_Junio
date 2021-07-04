import { NodoXML } from '../parser/Nodes/NodoXml';
import { EnvironmentXML } from '../parser/Symbol/EnviromentXML';
import { Error_ } from '../parser/Error';
import { errores } from '../parser/Errores';
import { XQuerySymbol, TypeXQuery } from '../parser/Symbol/xquerySymbol';
import { EnvironmentXQuery } from '../parser/Symbol/EnviromentXQueryTrad';
import { element } from 'protractor';
import { _Console } from '../parser/Util/Salida';

//traducciones

export class TraductorXQuery {
  constructor() {}

  traducir(ast: NodoXML, envXML: EnvironmentXML, envXQuery: EnvironmentXQuery) {
    console.log(_Console.count);
    console.log(_Console.heapPointer);
    console.log(_Console.stackPointer);
    console.log(_Console.heapPointer2);
    console.log(_Console.stackPointer2);
    console.log(_Console.labels);
    console.log(_Console.salida);
    // console.log(ast);
    if (ast != null) {
      let tipo = ast.getTipo();
      console.log(tipo);
      switch (tipo) {
        case 'LExpresiones':
          ast.getHijos().forEach((element) => {
            this.traducir(element, envXML, envXQuery);
          });
          break;
        case 'Let':
          this.traducirLet(ast, envXML, envXQuery);
          break;
      }
    }
    return '//traduccion\n' + _Console.salida;
  }

  private traducirLet(
    ast: NodoXML,
    envXML: EnvironmentXML,
    envXQuery: EnvironmentXQuery
  ) {
    console.log(ast, 'ejecutando let');
    //var name
    let varName = ast.getHijos()[0].name;
    //expresion
    let exp = ast.getHijos()[1];
    switch (exp.getTipo()) {
      case 'TO':
        // (exp to exp)
        break;
      case ',':
        // (exp , exp)
        break;
      case 'ExprLogica':
        // logica
        break;
      case 'Expr':
        // aritmetica
        break;
      case 'Exp':
        // xpath
        break;
      case 'Lexp':
        // xpath
        break;
      case 'Syntfin':
        // xpath
        break;
      case 'Fin':
        //valor || funcion xpath
        if (exp.type == exp.name) {
          //valor opc || preservada opc
          if (!exp.listaNodos[1]) {
            var val = this.traducirValor(exp.listaNodos[0], envXML, envXQuery);
            //traducir
            var c = _Console.count;
            var h = _Console.heapPointer;
            var s = _Console.stackPointer;
            _Console.salida += `// let ${varName}=${val[0]}\n`;
            _Console.salida += `t${c}=hxquery;\n`;
            _Console.salida += `HeapXQuery[(int)hxquery] = ${val[0]};\n`;
            _Console.salida += `hxquery = hxquery + 1;\n`;
            _Console.salida += `StackXQuery[(int)${s}] = t${c};\n\n`;
            _Console.count++;
            _Console.heapPointer++;
            _Console.stackPointer++;
            //agregar a tabla de simbolos
            var sym = new XQuerySymbol(
              val[1],
              varName,
              val[0],
              exp.line,
              exp.column,
              envXQuery.nombre
            );
            sym.setPosicion(s);
            envXQuery.addSimbolo(sym);
          }
        }
        break;
      default:
        break;
    }
  }

  private traducirValor(
    ast: NodoXML,
    envXML: EnvironmentXML,
    envXQuery: EnvironmentXQuery
  ) {
    switch (ast.type) {
      case 'ID':
        break;
      case 'NUMBER':
        return [ast.name, 1];
      case 'STRING':
        return [ast.name, 2];
      case 'VARIABLE':
        break;
      default:
        break;
    }
  }
}
