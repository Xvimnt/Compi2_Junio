import { Component, OnInit } from '@angular/core';
// Import para las graficas
import * as vis from "vis";
// Import para el servicio
import { DotService } from "../../services/dot.service" 

@Component({
  selector: 'app-ast',
  templateUrl: './ast.component.html',
  styleUrls: ['./ast.component.css']
})
export class AstComponent implements OnInit {

  constructor(private dotService: DotService) { }

  ngOnInit(): void {
    let dotRes = this.dotService.getDot();
    //alert(dotRes);
    var parsedData = vis.network.convertDot(dotRes);
    var data = {
      nodes: parsedData.nodes,
      edges: parsedData.edges
    };
    var options = parsedData.options;
    var container = document.getElementById("graph");
    var network = new vis.Network(container, data, options);
  }

}
