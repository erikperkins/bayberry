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
      let nodes = d3.selectAll(".digit-image").nodes()

      let j = Math.floor(d3.randomUniform(0, nodes.length)())
      i = (i == j) ? (i + 1) % 10 : j
      var node = d3.select(nodes[i])

      let fadeout = d3.transition().duration(250)
      let fadein = d3.transition().duration(250)

      node.transition(fadeout).style("opacity", 0)
        .on("end", function() {
          let url = `data:image/png;base64,${payload.image}`
          node.attr("xlink:href", () => url)

          node.transition(fadein).style("opacity", 1)

          $(this).tooltip("hide")
            .attr("data-original-title", payload.classification)
            .tooltip("setContent")

          $(this).filter(":hover").tooltip("show")
        })
    }

    function cloud(digits) {
      let
        width = 200,
        height = 200,
        imageWidth = 28,
        imageHeight = 28

      let svg = d3.select("#digitcloud")
        .attr("width", width)
        .attr("height", height)

      let group = svg.append("g")
        .attr("transform", `translate(${width/2},${height/2})`)

      let bodies = d3.forceSimulation(digits)
        .force("charge", d3.forceManyBody().strength(-10/digits.length))
        .force("collide", d3.forceCollide(14 * Math.sqrt(2)))
        .force("center", d3.forceCenter(-(imageWidth/2), -(imageHeight/2)))
        .on("tick", move)

      let images = group.selectAll(".digit")
        .data(digits).enter()
        .append("image")
        .attr("class", "digit-image")
        .attr("width", imageWidth)
        .attr("height", imageHeight)
        .attr("xlink:href", d => `data:image/png;base64,${d.image}`)
        .attr("data-toggle", "tooltip")
        .attr("data-placement", "left")
        .attr("title", d => d.classification)

        let template = [
          '<div class="digit tooltip" role="tooltip">',
          '<div class="tooltip-inner"></div>',
          '<div class="arrow"></div>',
          '</div>'
        ].join('')

      $(".digit-image").tooltip({template: template, animation: false})

      function move() {
        images.attr("x", d => d.x).attr("y", d => d.y)
      }
    }
  }
}
