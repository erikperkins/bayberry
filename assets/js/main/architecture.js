import {Socket} from "phoenix"

export var Architecture = {
  run: function() {
    d3.json("/sketch", (error, json) => { if (!error) draw(json) })

    function draw(json) {
      let
        width = 200,
        height = 200

      let
        svg =
          d3.select("#architecture")
            .attr("width", 200)
            .attr("height", 200),
        path =
          svg.append("g")
            .selectAll("path")
            .data([json]).enter()
            .append("path")
            .attr("d", d => d.d)
            .attr("transform", "translate(8,0)")

      let
        length = path.node().getTotalLength(),
        sketch = document.createElement("style"),
        sketchKeyFrames =
          `@keyframes sketch {
            from { stroke-dashoffset: 0; }
            to { stroke-dashoffset: -LENGTH; }
          }`

      sketch.type = "text/css"
      sketch.innerHTML = sketchKeyFrames.replace(/LENGTH/g, length)
      document.getElementsByTagName("head")[0].appendChild(sketch)

      path.style("fill", "none")
        .attr("class", "architecture")
        .style("stroke-dasharray", length)
    }
  }
}
