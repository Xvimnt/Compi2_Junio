export class XMLTag {
  public name: string;
  public val: string;
  public attr: Map<string, string> = new Map<string, string>();

  constructor(name: string, val: string, attr: any) {
    this.name = name;
    this.val = val;
    if (attr) {
      this.attr.set(attr.id, attr.value);
    }
  }

  htmlRow() {
    let result = `<td>${this.val}</td><td>${this.name}</td><td>${this.name}</td><td>${this.name}</td>`;
  }
}
