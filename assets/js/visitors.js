export var VisitorMap = {
  run: function() {
    var
      width = 640,
      height = 480,
      coordinates = [95, -39, 0],
      scale = 800,
      drag = d3.drag(),
      zoom = d3.zoom()

    var projection = d3.geoOrthographic()
      .scale(scale)
      .translate([width/2, height/2])
      .rotate(coordinates)

    var svg = d3.select("#visitor-map")
      .attr("width", width)
      .attr("height", height)
      .attr("class", "map")
      .call(drag.on("drag", () => { rotate(d3.event) }))
      .call(zoom.on("zoom", () => { rescale(d3.event.transform) }))

    var
      path = d3.geoPath().projection(projection),
      ocean = d3.geoCircle().center([0, 90]).radius(180)

    svg.append("rect")
      .attr("width", width)
      .attr("height", height)
      .attr("fill", "black")

    function rotate(event) {
      coordinates[0] += event.dx / 5
      coordinates[1] -= event.dy / 5
      projection.rotate(coordinates)

      d3.selectAll("path").attr("d", path)
      d3.select(".ocean").selectAll("path")
        .attr("d", () => { return path(ocean()) })

      d3.select(".visitors").selectAll("circle")
        .attr("cx", (d) => { return projection(d)[0] })
        .attr("cy", (d) => { return projection(d)[1] })
    }

    function rescale(transform) {
      projection.scale(scale * transform.k)

      d3.selectAll("path").attr("d", path)
      d3.select(".ocean").selectAll("path")
        .attr("d", () => { return path(ocean()) })

      d3.select(".visitors").selectAll("circle")
        .attr("cx", (d) => { return projection(d)[0] })
        .attr("cy", (d) => { return projection(d)[1] })
        .attr("r", (d) => { return 4 * Math.log(1 + transform.k) })
    }

    function draw(world, locations) {
      svg.append("g")
        .attr("class", "ocean")
        .selectAll("path")
        .data([0])
        .enter().append("path")
        .attr("d", () => { return path(ocean()) })

      svg.append("g")
        .attr("class", "boundary")
        .selectAll("boundary")
        .data(topojson.feature(world, world.objects.countries).features)
        .enter().append("path")
        .attr("name", function(d) { return d.properties.name })
        .attr("id", function(d) { return d.id })
        .attr("d", path)

      svg.append("g")
        .attr("class", "boundary state")
        .selectAll("boundary")
        .data(topojson.feature(world, world.objects.states).features)
        .enter().append("path")
        .attr("name", function(d) { return d.properties.name })
        .attr("id", function(d) { return d.id })
        .attr("d", path)

      svg.append("g")
        .attr("class", "visitors")
        .selectAll("circle")
        .data(locations).enter()
        .append("circle")
        .attr("cx", (d) => { return projection(d)[0] })
        .attr("cy", (d) => { return projection(d)[1] })
        .attr("r", 4 * Math.log(2))
        .attr("fill", "darkorange")
    }

    d3.json("/accounts/administration/world_map", (error, world) => {
      if (error) return console.error(error)
      d3.json("/accounts/administration/locations", (error, locations) => {
        if (error) return console.error(error)
        draw(world, locations)
      })
    })
  }
}
