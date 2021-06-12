import { errores } from '../Errores';
import { Error_ } from '../Error';
import { XMLTag } from './XMLTag';

export class EnvironmentXML {
  public tags: Map<string, XMLTag>;

  constructor(public anterior: EnvironmentXML | null) {
    this.anterior = anterior;
    this.tags = new Map<string, XMLTag>();
  }

  public addTag(name: string, value: string) {}
}
