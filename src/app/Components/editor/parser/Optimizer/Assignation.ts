import { Expression } from "../Abstract/Expression";
import { Arithmetic } from '../Expression/Arithmetic';
import { Literal } from "../Expression/Literal";
import { _Optimizer } from './Optimizer';
import { Rule } from "./Rule";
export class Assignation {

    constructor(public id: string, public expr: Expression, public line: number, column: number) { }

    build(): string {
        return this.id + " = " + this.expr.build() + ";\n";
    }

    regla1(env: _Optimizer) {
        env.temp += this.build();
    }
    regla2(env: _Optimizer) {
        env.salida += this.build();
    }
    regla3(env: _Optimizer) {
        env.salida += this.build();
    }
    regla4(env: _Optimizer) {
        env.salida += this.build();
    }

    regla5(env: _Optimizer) {
        if (this.expr instanceof Literal) {
            if (this.id == env.temp) {
                env.flag = true;
            }
            else if (env.label == this.id && env.temp == this.expr.value && !env.flag) {
                env.reglas.push(new Rule(this.line, 'Mirilla', "Regla 5", this.build(), ""));
                return;
            }
            else {
                env.temp = this.id;
                env.label = this.expr.value;
                env.flag = false;
            }

        }
        env.salida += this.build();
    }

    optimize(env: _Optimizer) {
        env.salida += this.build();
    }
}