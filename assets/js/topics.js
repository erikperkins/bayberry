export var LdaTopics = {
  run: function() {
    var bubbles = renderBubbles()

    d3.json('http://main.datapun.net:1025/lda', function(errors, json) {
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
  var svg = d3.select("#pack"),
    margin = 0,
    diameter = 200,
    bubbles = svg.append("g")
      .attr("class", "bubbles")
      .attr("id", "wait")
      .attr("transform", `translate(${diameter / 2},${diameter / 2})`)

  return setInterval(() => { bubble(bubbles) }, 20)
}

function bubble(bubbles) {
  var
    grow = d3.transition().duration(1000).ease(d3.easeLinear),
    fade = d3.transition().duration(25),
    rho = d3.randomUniform(0, 100),
    theta = d3.randomUniform(0, 2 * Math.PI),
    cx = rho() * Math.cos(theta()),
    cy = rho() * Math.sin(theta())

  var circle = bubbles.append("circle")
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

function renderLdaPack(root) {
  var svg = d3.select("#pack"),
      margin = 0,
      diameter = 200,
      g = svg.append("g")
        .attr("class", "g-fade-in")
        .attr("transform", `translate(${diameter / 2},${diameter / 2})`)

  var pack = d3.pack()
    .size([diameter - margin, diameter - margin])
    .padding(2);

  root = d3.hierarchy(root)
    .sum(function(d) { return d.size; })
    .sort(function(a, b) { return b.value - a.value; });

  var
    nodes = pack(root).descendants(),
    focus = root,
    view

  var circle = g.selectAll("circle")
    .data(nodes)
    .enter().append("circle")
    .attr("class", function(d) {
      return d.parent ? (d.children ? "node" : "node--leaf") : "node--root"
    })

  var text = g.selectAll("text")
    .data(nodes)
    .enter().append("text")
    .attr("class", (d) => {
      return d.parent === root ? "d3-label" : "hidden"
    }).text(function(d) { return d.data.name })

  var node = g.selectAll("circle,text").on("click", function(d) {
    if (focus !== d) zoom(d), d3.event.stopPropagation();
  })

  svg.style("background", "white")
    .on("click", function() { zoom(root); });

  zoomTo([root.x, root.y, root.r * 2 + margin]);

  function zoom(d) {
    var
      _focus = focus
      focus = d

    var transition = d3.transition()
      .duration(d3.event.altKey ? 7500 : 750)
      .tween("zoom", function(d) {
        var i = d3.interpolateZoom(view, [focus.x, focus.y, focus.r * 2 + margin]);
        return function(t) { zoomTo(i(t)); };
      });

    svg.selectAll("text").transition(transition)
      .attr("class", function(d) {
        return d.parent === focus ? "d3-label fadein" : "d3-label hidden"
      })
  }

  function zoomTo(v) {
    var k = diameter / v[2]; view = v;
    node.attr("transform", function(d) {
      return `translate(${(d.x - v[0]) * k},${(d.y - v[1]) * k})`
    })
    circle.attr("r", function(d) { return d.r * k });
  }
}
