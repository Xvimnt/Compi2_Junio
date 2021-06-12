import { Nodo } from '../Abstract/Nodo';

export class NodoXML extends Nodo {
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

  public plot(count: number): string {
    let result = `node${count} [label="(${this.line},${this.column}) ${this.name} (${this.type})"]`;
    return result;
  }

  public addHijo(nodo: NodoXML): void {
    this.listaNodos.push(nodo);
  }

  public getHijos() {
    return this.listaNodos;
  }
}
