import {Socket} from "phoenix"

export var Visitors = {
  run: function() {

    let socket = new Socket(
      "/socket",
      {params: {token: window.userToken}}
    )
    socket.connect()

    let channel = socket.channel("geolocation:visitor", {})

    channel.on("visit", payload => {
      if (payload.latitude && payload.longitude) {
        drawPoint(payload)
      }
    })

    var
      width = 200,
      height = 200,
      coordinates = [95, -39, 0],
      scale = 100,
      altitude = scale,
      drag = d3.drag(),
      zoom = d3.zoom(),
      visitors

    var projection = d3.geoOrthographic()
      .scale(scale)
      .clipAngle(90)
      .translate([width/2, height/2])
      .rotate(coordinates)

    let svg = d3.select("#visitor-map")
      .attr("width", width)
      .attr("height", height)
      .call(drag.on("drag", () => rotate(d3.event)))
      .call(zoom.on("zoom", () => rescale(d3.event.transform)))

    var
      path = d3.geoPath().projection(projection).pointRadius(2),
      ocean = d3.geoCircle().center([0, 90]).radius(180)

    var globe = svg.append("g")

    d3.json("/api/world_map", (error, world) => {
      if (error) return console.error(error)
      drawMap(world)
    })

    function drawMap(world) {
      globe.append("g")
        .attr("class", "ocean")
        .selectAll("path")
        .data([0])
        .enter().append("path")
        .attr("d", () => path(ocean()))

      globe.append("path")
        .datum(world)
        .attr("class", "boundary")
        .attr("d", path)

      visitors = globe.append("g")
        .attr("class", "visitors")

      channel.join()
        .receive("ok", _ => console.log("Joined channel geolocation:visitor"))

      channel.push("stream-visits", {})
    }

    function drawPoint(payload) {
      let location = [payload.longitude, payload.latitude]

      visitors.append("path")
        .datum({type: "Point", coordinates: location, bot: payload.bot})
        .attr("class", d => visitorClass(d))
        .attr("d", path)
    }

    function visitorClass(datum) {
      return datum.bot ? "bot" : "visitor"
    }

    function rotate(event) {
      coordinates[0] += (180/Math.PI) * Math.asin(event.dx/altitude + 1e-6)
      coordinates[1] -= (180/Math.PI) * Math.asin(event.dy/altitude + 1e-6)

      projection.rotate(coordinates)

      svg.selectAll("path").attr("d", path)

      svg.select(".ocean").selectAll("path")
        .attr("d", () => path(ocean()))

      svg.select(".visitors").selectAll("circle")
        .attr("cx", d => projection(d)[0])
        .attr("cy", d => projection(d)[1])
    }

    function rescale(transform) {
      transform.k = transform.k < 1 ? 1 : transform.k
      altitude = scale * transform.k
      projection.scale(altitude)

      svg.selectAll("path").attr("d", path)

      svg.select(".ocean").selectAll("path")
        .attr("d", () => path(ocean()))

      svg.select(".visitors").selectAll("circle")
        .attr("cx", d => projection(d)[0])
        .attr("cy", d => projection(d)[1])
        .attr("r", d => 4 * Math.sqrt(transform.k))
    }
  }
}
