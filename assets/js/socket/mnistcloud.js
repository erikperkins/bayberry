import {Socket} from "phoenix"

export var DigitCloud = {
  run: () => {
    let socket = new Socket("/mnistsocket", {params: {token: window.userToken}})
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

      d3.select(nodes[i])
        .attr("xlink:href", () => `data:image/png;base64,${payload.image}`)
        .html(() => `<title>${payload.classification}</title>`)
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
