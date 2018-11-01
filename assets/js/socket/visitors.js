import {Socket} from "phoenix"

export var VisitorMap = {
  run: function() {

    let socket = new Socket("/geolocationsocket", {params: {token: window.userToken}})
    socket.connect()

    let channel = socket.channel("geolocation:visitor", {})

    channel.on("visit", payload => {
      if (payload.latitude && payload.longitude) {
        drawPoint([payload.longitude, payload.latitude])
      }
    })

    channel.join()
      .receive("ok", _ => {
        console.log("Joined channel geolocation:visitor successfully")
        d3.json("/administration/world_map", (error, world) => {
          if (error) return console.error(error)
          drawMap(world)
        })
      })

    var
      width = 640,
      height = 480,
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

    var svg = d3.select("#visitor-map")
      .attr("width", width)
      .attr("height", height)
      .attr("class", "map")
      .call(drag.on("drag", () => { rotate(d3.event) }))
      .call(zoom.on("zoom", () => { rescale(d3.event.transform) }))

    var
      path = d3.geoPath().projection(projection).pointRadius(1),
      ocean = d3.geoCircle().center([0, 90]).radius(180)

    svg.append("rect")
      .attr("width", width)
      .attr("height", height)
      .attr("fill", "black")

    var globe = svg.append("g")

    function drawMap(world) {
      globe.append("g")
        .attr("class", "ocean")
        .selectAll("path")
        .data([0])
        .enter().append("path")
        .attr("d", () => { return path(ocean()) })

      globe.append("g")
        .attr("class", "boundary")
        .selectAll("boundary")
        .data(topojson.feature(world, world.objects.countries).features)
        .enter().append("path")
        .attr("name", function(d) { return d.properties.name })
        .attr("id", function(d) { return d.id })
        .attr("d", path)

      globe.append("g")
        .attr("class", "boundary")
        .selectAll("boundary")
        .data(topojson.feature(world, world.objects.states).features)
        .enter().append("path")
        .attr("name", function(d) { return d.properties.name })
        .attr("id", function(d) { return d.id })
        .attr("d", path)

        visitors = globe.append("g")
          .attr("class", "visitors")

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
      coordinates[0] += (180/Math.PI) * Math.asin(event.dx/altitude)
      coordinates[1] -= (180/Math.PI) * Math.asin(event.dy/altitude)

      projection.rotate(coordinates)

      d3.selectAll("path").attr("d", path)
      d3.select(".ocean").selectAll("path")
        .attr("d", () => { return path(ocean()) })

      d3.select(".visitors").selectAll("circle")
        .attr("cx", (d) => { return projection(d)[0] })
        .attr("cy", (d) => { return projection(d)[1] })
    }

    function rescale(transform) {
      altitude = scale * transform.k
      projection.scale(altitude)

      d3.selectAll("path").attr("d", path)
      d3.select(".ocean").selectAll("path")
        .attr("d", () => { return path(ocean()) })

      d3.select(".visitors").selectAll("circle")
        .attr("cx", (d) => { return projection(d)[0] })
        .attr("cy", (d) => { return projection(d)[1] })
        .attr("r", (d) => { return 4 * Math.log(1 + transform.k) })
    }
  }
}
