// import { count } from 'console';

export class Plotter {
  count: number;
  public makeDot(ast: any) {
    let count = 1;
    let result = 'digraph AST{ node[shape="box"];';
    result += 'node' + count + '[label="(0,0) Inicio"];';
    result += this.printAST(ast, count);
    // if (ast != null) {

    //     for (const instr of ast) {
    //         result += instr.plot(Number(count + '1'));
    //         // Flechas
    //         result += "node1 -> " + "node" + count + "1;";
    //         count++;
    //     }
    // }
    return result + '}';
  }

  private printAST(ast: any, count: number): string {
    var res = '';
    if (ast != null) {
      res += ast.plot(Number(count + '1'));
      res += 'node1 -> ' + 'node' + count + '1;';
      count++;
      ast.getHijos().forEach((element) => {
        res += this.printAST(element, count);
      });
    }
    return res;
  }
}
