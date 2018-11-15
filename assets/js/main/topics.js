export var Topics = {
  run: function() {
    let bubbles = renderBubbles()

    d3.json('/api/topics', function(errors, json) {
      if (!errors) {
        setTimeout(() => {
          clearInterval(bubbles)
          renderLdaPack(json)
        }, 500)
      }
    })
  }
}

function renderBubbles() {
  let svg = d3.select("#pack"),
    diameter = 200,
    bubbles = svg.append("g")
      .attr("class", "bubbles")
      .attr("id", "wait")
      .attr("transform", `translate(${diameter/2},${diameter/2})`)

  return setInterval(() => { bubble(bubbles) }, 20)
}

function bubble(bubbles) {
  let
    diameter = 200,
    grow = d3.transition().duration(750).ease(d3.easeLinear),
    fade = d3.transition().duration(40),
    rho = (diameter/2) * Math.floor(d3.randomUniform(1, 8)()) / 8,
    theta = (2*Math.PI) * Math.floor(d3.randomUniform(0, 16)()) / 16,
    cx = rho * Math.cos(theta),
    cy = rho * Math.sin(theta)

  let circle = bubbles.append("circle")
    .attr("class", "bubble")
    .attr("cx", cx)
    .attr("cy", cy)
    .attr("r", 1)
    .transition(grow)
    .attr("r", 25)
    .transition(fade)
    .attr("class", "bubble-fade")
    .remove()
}

function renderLdaPack(json) {
  let
    svg = d3.select("#pack"),
    diameter = 200,
    group =
      svg.append("g")
        .attr("class", "g-fade-in")
        .attr("transform", `translate(${diameter/2},${diameter/2})`)

  let pack =
    d3.pack()
      .size([diameter, diameter])
      .padding(2)

  let root =
    d3.hierarchy(json)
      .sum(d => d.size)
      .sort((a, b) => b.value - a.value)

  let
    view,
    focus = root,
    descendants = pack(root).descendants()

  let circle =
    group.selectAll("circle")
      .data(descendants)
      .enter().append("circle")
      .attr("class", d => d.parent ? (d.children ? "node" : "leaf") : "root")
      .on("click", d => { if (focus !== d) zoom(d), d3.event.stopPropagation() })

  let text =
    group.selectAll("text")
      .data(descendants)
      .enter().append("text")
      .attr("class", d => d.parent === root ? "topic" : "term")
      .style("display", d => d.parent === root ? "inline" : "none")
      .text(d => d.data.name)

  var nodes = group.selectAll("circle,text")

  svg.style("background", "white")
   .on("click", () => zoom(root))

  zoomTo([root.x, root.y, 2*root.r]);

  function zoom(d) {
    let _focus = focus
    focus = d

    let transition =
      d3.transition()
        .duration(500)
        .tween("zoom", function(d) {
          let interpolate =
            d3.interpolateZoom(view, [focus.x, focus.y, 2 * focus.r]);

          return function(t) { zoomTo(interpolate(t)); };
        })

    transition.selectAll("text")
      .filter(function(d) {
        return d.parent === focus || this.style.display === "inline"
      }).style("fill-opacity", d => d.parent === focus ? 1 : 0)
      .on("end", function(d) {
        if (d.parent === focus) {
          this.style.display = "inline"
        } else this.style.display = "none"
      })
  }

  function zoomTo(v) {
    let k = diameter / v[2]
    view = v

    nodes.attr("transform", d => `translate(${(d.x-v[0])*k},${(d.y-v[1])*k})`)

    circle.attr("r", d =>  d.r * k)
  }
}
