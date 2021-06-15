import { errores } from '../Errores';
import { Error_ } from '../Error';
import { XMLSymbol } from '../Symbol/xmlSymbol';

export class EnvironmentXML {
  public nombre: string;
  public anterior: EnvironmentXML;
  public tablaSimbolos: Array<XMLSymbol>;

  constructor(nombre, anterior) {
    this.nombre = nombre;
    this.anterior = anterior;
    this.tablaSimbolos = new Array<XMLSymbol>();
  }

  addSimbolo(simbolo: XMLSymbol) {
    //check only if is attr
    if (simbolo.getTipo() === 'Atributo') {
      let tmp = this.tablaSimbolos;
      for (let index = 0; index < tmp.length; index++) {
        if (
          tmp[index].getNombre() === simbolo.getNombre() &&
          tmp[index].getTipo() === simbolo.getTipo()
        ) {
          //error semantico se declaro dos veces el atributo
          console.error(
            'el atributo -> ' + simbolo.getNombre() + ' ya existe;'
          );
          errores.push(
            new Error_(
              simbolo.getFila(),
              simbolo.getColumna(),
              'Semantico',
              "el atributo -> ' + simbolo.getNombre() + ' ya existe;"
            )
          );
          return;
        }
      }
      this.tablaSimbolos.push(simbolo);
      return;
    }
  }

  // getSimbolo(nombre) {
  //   var ent = this;
  //   while (ent != null) {
  //     var tmp = ent.tablaSimbolos.getTabla();
  //     for (let index = 0; index < tmp.length; index++) {
  //       if (tmp[index].getNombre() === nombre) {
  //         return tmp[index];
  //       }
  //     }
  //     ent = ent.anterior;
  //   }
  //   return false;
  // }

  // updateSimbolo(simbol) {
  //   var ent = this;
  //   while (ent != null) {
  //     var tmp = ent.tablaSimbolos.getTabla();
  //     for (let index = 0; index < tmp.length; index++) {
  //       if (tmp[index].getNombre() === simbol.getNombre()) {
  //         tmp[index] = simbol;
  //         return true;
  //       }
  //     }
  //     ent = ent.anterior;
  //   }
  //   return false;
  // }

  printEntornos() {
    let ent: EnvironmentXML = this;
    while (ent != null) {
      console.log(ent.nombre);
      ent = ent.anterior;
    }
  }

  printTablaSimbolos() {
    let ent: EnvironmentXML = this;
    while (ent != null) {
      var tmp = ent.tablaSimbolos;
      tmp.forEach((element) => {
        console.log(element);
      });
      ent = ent.anterior;
    }
  }

  getTablaSimbolos() {
    let ent: EnvironmentXML = this;
    let simb = new Array();
    while (ent != null) {
      let tmp = ent.tablaSimbolos;
      tmp.forEach((element) => {
        simb.push(element);
      });
      ent = ent.anterior;
    }
    return simb;
  }
}
