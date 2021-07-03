import { EjecutorXPath } from "../../ejecutor/ejecutorXPath";
import { Expression } from "../Abstract/Expression";
import { Instruction } from "../Abstract/Instruction";
import { NodoXML } from "../Nodes/NodoXml";
import { Environment } from "../Symbol/Environment";
import { _Console } from '../Util/Salida';
import { Fin } from "./Fin";

export class ForAssign extends Instruction {

    constructor(private variable1: Expression, private variable2: Expression, private clause: Array<Fin>, line: number, column: number) {
        super(line, column);
    }

    public execute(env: Environment) {
        try {
            // Hacer la consulta a xpath
            var xmlClause = new NodoXML("xmlClause", "xmlClause",0,0);
            this.clause.forEach(element => {
                xmlClause.addHijo(element.tree);
            });
            let ejecutor = new EjecutorXPath(env.xmlEnvironment);
            let result = ejecutor.ejecutar(xmlClause);

            console.log("clause result", result);
        } catch (e) {
            console.error(e);
        }
    }

    public translate(environment: Environment): String {
        let result = "// Inicia ForIn\n";
        return result;
    }

    public plot(count: number): string {
        let result = "node" + count + "[label=\"(" + this.line + "," + this.column + ") Foreach\"];";
        // result += "node" + count + "3[label=\"(" + this.code.line + "," + this.code.column + ") Codigo\"];";
        // result += this.code.plot(Number(count + "3"));
        // // Flechas
        // result += "node" + count + " -> " + "node" + count + "1;";
        // result += "node" + count + " -> " + "node" + count + "3;";

        return result;

    }



}