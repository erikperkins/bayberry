import {Socket} from "phoenix"

export var Visitors = {
  run: function() {

    let socket = new Socket(
      "/geolocationsocket",
      {params: {token: window.userToken}}
    )
    socket.connect()

    let channel = socket.channel("geolocation:visitor", {})

    channel.on("visit", payload => {
      if (payload.latitude && payload.longitude) {
        drawPoint([payload.longitude, payload.latitude])
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
      locations = [],
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

    d3.json("/world_map", (error, world) => {
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

    function drawPoint(location) {
      locations.push(location)

      visitors.append("path")
        .datum({type: "MultiPoint", coordinates: locations})
        .attr("class", "location")
        .attr("d", path)
    }

    function rotate(event) {
      coordinates[0] += (180/Math.PI) * Math.asin(event.dx/altitude + 1e-6)
      coordinates[1] -= (180/Math.PI) * Math.asin(event.dy/altitude + 1e-6)

      projection.rotate(coordinates)

      d3.selectAll("path").attr("d", path)
      d3.select(".ocean").selectAll("path")
        .attr("d", () => path(ocean()))

      d3.select(".visitors").selectAll("circle")
        .attr("cx", d => projection(d)[0])
        .attr("cy", d => projection(d)[1])
    }

    function rescale(transform) {
      altitude = scale * transform.k
      projection.scale(altitude)

      d3.selectAll("path").attr("d", path)
      d3.select(".ocean").selectAll("path")
        .attr("d", () => path(ocean()))

      d3.select(".visitors").selectAll("circle")
        .attr("cx", d => projection(d)[0])
        .attr("cy", d => projection(d)[1])
        .attr("r", d => 4 * Math.log(1 + transform.k))
    }
  }
}
