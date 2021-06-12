export abstract class Nodo {
  public line: number;
  public column: number;
  public name: string;
  public type: string;
  public listaNodos;

  constructor(name: string, type: string, line: number, column: number) {
    this.name = name;
    this.type = type;
    this.line = line;
    this.column = column;
    this.listaNodos = new Array();
  }

  public abstract addHijo(nodo: any): void;

  public abstract plot(count: number): string;
}
