import {Socket} from "phoenix"

export var Digits = {
  run: () => {
    let socket = new Socket("/socket", {params: {token: window.userToken}})
    socket.connect()
    let channel = socket.channel("mnist:digit", {})

    channel.join()
      .receive("ok", () => console.log("Joined mnist:digit"))
      .receive("error", () => console.log("Unable to join mnist:digit"))

    channel.on("digit-stream", payload => replaceDigit(payload))

    channel.push("digits", {})
      .receive("digits", payload => cloud(payload.digits))

    function replaceDigit(payload) {
      var nodes = d3.selectAll(".digit").nodes()
      var i = Math.floor(d3.randomUniform(0, nodes.length)())
      var node = d3.select(nodes[i])

      var fadeout = d3.transition().duration(250)
      var fadein = d3.transition().duration(250)

      node.transition(fadeout).style("opacity", 0)
        .on("end", () => {
          let url = `data:image/png;base64,${payload.image}`
          node.attr("xlink:href", () => url)
            .html(() => `<title>${payload.classification}</title>`)

          node.transition(fadein).style("opacity", 1)
        })
    }

    function cloud(digits) {
      let
        width = 200,
        height = 200

      var svg = d3.select("#digitcloud")
        .attr("width", width)
        .attr("height", height)

      var group = svg.append("g")
        .attr("transform", `translate(${width/2},${height/2})`)

      var bodies = d3.forceSimulation(digits)
        .force("charge", d3.forceManyBody().strength(-10/digits.length))
        .force("collide", d3.forceCollide(14 * Math.sqrt(2)))
        .force("center", d3.forceCenter(-14, -14))
        .on("tick", update)

      function update() {
        var selection = group.selectAll(".digit").data(digits)

        selection.enter()
          .append("image")
          .attr("class", "digit")
          .attr("xlink:href", d => `data:image/png;base64,${d.image}`)
          .html(d => `<title>${d.classification}</title>`)
          .merge(selection)
          .attr("x", d => d.x)
          .attr("y", d => d.y)

        selection.exit().remove()
      }
    }
  }
}
