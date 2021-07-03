import { Expression } from "../Abstract/Expression";
import { Instruction } from "../Abstract/Instruction";
import { Environment } from "../Symbol/Environment";
import { _Console } from '../Util/Salida';

export class ForAssign extends Instruction {

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

    constructor(private variable1: Expression, private variable2: Expression, private clause, line: number, column: number) {
        super(line, column);
    }

    public execute(env: Environment) {

    }
}