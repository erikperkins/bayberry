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

    let i = 0

    function replaceDigit(payload) {
      let nodes = d3.selectAll(".digit").nodes()

      let j =  Math.floor(d3.randomUniform(0, nodes.length)())
      i = (i == j) ? (i + 1) % 10 : j
      var node = d3.select(nodes[i])

      let fadeout = d3.transition().duration(250)
      let fadein = d3.transition().duration(250)

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

      let svg = d3.select("#digitcloud")
        .attr("width", width)
        .attr("height", height)
        .style("fill", "red")

      let group = svg.append("g")
        .attr("transform", `translate(${width/2},${height/2})`)

      let bodies = d3.forceSimulation(digits)
        .force("charge", d3.forceManyBody().strength(-10/digits.length))
        .force("collide", d3.forceCollide(14 * Math.sqrt(2)))
        .force("center", d3.forceCenter(-14, -14))
        .on("tick", update)

      function update() {
        let selection = group.selectAll(".digit").data(digits)

        selection.enter()
          .append("image")
          .attr("class", "digit")
          .attr("xlink:href", d => `data:image/png;base64,${d.image}`)
          .attr("width", 28)
          .attr("height", 28)
          .html(d => `<title>${d.classification}</title>`)
          .merge(selection)
          .attr("x", d => d.x)
          .attr("y", d => d.y)

        selection.exit().remove()
      }
    }
  }
}
