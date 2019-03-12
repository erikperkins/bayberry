export var Timeseries = {
  update: function(json) {
    let offset = 60

    let
      [p1, p0, ...p] =
        json["predicted"].sort((a, b) => a.time - b.time)
          .reverse().slice(0, offset),
      predicted = [...p.reverse(), p0],
      predictedNow = [p0, p1]

    let
      [o1, o0, ...o] =
        json["observed"].sort((a, b) => a.time - b.time)
          .reverse().slice(0, offset),
      observed = [...o.reverse(), o0],
      observedNow = [o0, o1]

    let
      all = [...predicted, ...predictedNow, ...observed, ...observedNow],
      max = d3.max(all, d => d.datum),
      domain = d3.extent(all, d => parse(d.time)),
      codomain = [0, max]

    time.domain(domain)
    tweets.domain(codomain)

    let line =
      d3.line()
        .x(d => time(parse(d.time)))
        .y(d => tweets(d.datum))

    predictedPath.attr("d", line(predicted))
    observedPath.attr("d", line(observed))

    predictedNowPath.attr("d", line(predictedNow))

    let tAxis = d3.axisBottom(time).ticks(5)
    tAxisLine.call(tAxis).transition(80)

    let yAxis = d3.axisLeft(tweets).ticks(5)
    yAxisLine.call(yAxis).transition(80)

    observedNowPath.transition(80).attr("d", line(observedNow))

    predictedLabel.attr(
      "transform",
      `translate(${time(parse(p1.time))},${tweets(p1.datum)})`
    )
    observedLabel.transition(80)
      .attr(
        "transform",
        `translate(${time(parse(o1.time))},${tweets(o1.datum)})`
      )
  }
}

let svg =
  d3.select("#tweets")
    .append("div")
    .classed("svg-container", true)
    .append("svg")
    .attr("preserveAspectRatio", "xMinYMin meet")
    .attr("viewBox", "0 0 640 320")

let
  margin = { top: 20, right: 85, bottom: 50, left: 85 },
  width = svg.attr("viewBox").split(" ")[2] - margin.left - margin.right,
  height = svg.attr("viewBox").split(" ")[3] - margin.top - margin.bottom,
  group = svg.append("g")
    .attr("transform", `translate(${margin.left},${margin.top})`)

group.append("rect")
  .attr("width", width)
  .attr("height", height)
  .attr("fill", "none")

let
  time = d3.scaleTime().range([0, width]),
  tweets = d3.scaleLinear().range([height, 0])

let endTime = new Date()
let beginTime = new Date()
beginTime.setMinutes(endTime.getMinutes() - 60)
time.domain([beginTime, endTime])
tweets.domain([0, 50])

let parse = function(d) { return new Date(parseInt(d) * 1000) }

let predictedPath =
  group.append("path")
    .attr("class", "timeseries predicted")

let observedPath =
  group.append("path")
    .attr("class", "timeseries observed")

let predictedNowPath =
  group.append("path")
    .attr("class", "timeseries predicted")
    .attr("stroke-dasharray", "2, 2")

let observedNowPath =
  group.append("path")
    .attr("class", "timeseries observed")
    .attr("stroke-dasharray", "2, 2")

let tAxisLine =
  group.append("g").attr("class", "axis")
    .attr("transform", `translate(0,${height})`)

tAxisLine.call(d3.axisBottom(time).ticks(5));

let yAxisLine = group.append("g").attr("class", "axis")
yAxisLine.call(d3.axisLeft(tweets).ticks(5))

let tAxisLabel =
  svg.append("text")
    .attr("class", "axis axis-label")
    .attr(
      "transform",
      `translate(${margin.left + width / 2},
        ${height + margin.bottom + margin.top / 2})`
    ).text("Time")

let yAxisLabel =
  group.append("text")
    .attr("class", "axis axis-label")
    .attr(
      "transform",
      `translate(${-2*margin.left/3},${height/2}) rotate(270)`
    ).text("Tweets per Minute")

let predictedLabel =
  group.append("g")
    .attr("transform", `translate(0,${height - 15})`)

predictedLabel.append("circle")
  .attr("class", "predicted-point")
  .attr("r", 3)

let predictedText =
  predictedLabel.append("foreignObject")
    .attr("width", "5em")
    .attr("height", "2em")
    .attr("x", 3)
    .attr("y", -12)

predictedText.append("xhtml:div")
  .append("div")
  .attr("class", "point-label")
  .text("predicted")

let observedLabel =
  group.append("g")
    .attr("transform", `translate(0,${height - 5})`)

observedLabel.append("circle")
  .attr("class", "observed-point")
  .attr("r", 3)

let observedText =
  observedLabel.append("foreignObject")
    .attr("width", "5em")
    .attr("height", "2em")
    .attr("x", 3)
    .attr("y", -12)

observedText.append("xhtml:div")
  .append("div")
  .attr("class", "point-label")
  .text("observed")
