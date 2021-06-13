import { Nodo } from '../Abstract/Nodo';

export class NodoXML extends Nodo {

  public plotCst(count: number): string {
    let result = `node${count} [label="(${this.line},${this.column}) ${this.name} (${this.type})"];\n`;
    this.getHijos().forEach(element => {
      result += "node${count} -> node${count}1;\n";
      result += element.plotCst((Number(count + "1")));
    });
    // Flechas
    return result;
  }

  public plotAst(count: number): string {
    throw new Error('Method not implemented.');
  }
  constructor(
    id: string,
    tipo: string,
    line: number,
    column: number,
    public val: any
  ) {
    super(id, tipo, line, column);
  }

  public getID() {
    return this.name;
  }

  public getVAl() {
    return this.val;
  }


  public addHijo(nodo: NodoXML): void {
    this.listaNodos.push(nodo);
  }

  public getHijos() {
    return this.listaNodos;
  }
}
