export var Timeseries = {
  update: function(json) {
    let offset = 60

    let
      [p1, p0, ...p] = json["predicted"].sort((a, b) => a.time - b.time)
        .reverse().slice(0, offset),
      predicted = [...p.reverse(), p0],
      predictedNow = [p0, p1]

    let
      [o1, o0, ...o] = json["observed"].sort((a, b) => a.time - b.time)
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

    let line = d3.line()
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

var
  svg = d3.select("svg").style("background-color", "white"),
  margin = { top: 20, right: 85, bottom: 50, left: 85 },
  width = svg.attr("width") - margin.left - margin.right,
  height = svg.attr("height") - margin.top - margin.bottom,
  group = svg.append("g").attr(
    "transform",
    `translate(${margin.left},${margin.top})`
  )

var
  time = d3.scaleTime().range([0, width]),
  tweets = d3.scaleLinear().range([height, 0])

let endTime = new Date()
let beginTime = new Date()
beginTime.setMinutes(endTime.getMinutes() - 60)
time.domain([beginTime, endTime])
tweets.domain([0, 50])

var parse = function(d) {
  var date = new Date(parseInt(d) * 1000)
  return date;
};

var predictedPath = svg.append("path")
  .attr("class", "timeseries predicted static")
  .attr("transform", `translate(${margin.left},${margin.top})`)

var observedPath = svg.append("path")
  .attr("class", "timeseries observed static")
  .attr("transform", `translate(${margin.left},${margin.top})`)

var predictedNowPath = svg.append("path")
  .attr("class", "timeseries predicted static")
  .attr("transform", `translate(${margin.left},${margin.top})`)
  .attr("stroke-dasharray", "2, 2")

var observedNowPath = svg.append("path")
  .attr("class", "timeseries observed dynamic")
  .attr("transform", `translate(${margin.left},${margin.top})`)
  .attr("stroke-dasharray", "2, 2")

var tAxisLine = svg.append("g").attr("class", "axis")
  .attr(
    "transform",
    `translate(${margin.left},${margin.top + height})`
  )
tAxisLine.call(d3.axisBottom(time).ticks(5));

var yAxisLine = svg.append("g").attr("class", "axis")
  .attr("transform",
   `translate(${margin.left},${margin.top})`
 )
yAxisLine.call(d3.axisLeft(tweets).ticks(5))

var tAxisLabel = svg.append("text").attr("class", "axis axis-label")
  .attr(
    "transform",
    `translate(${margin.left + width / 2},
      ${height + margin.bottom + margin.top / 2})`
  ).style("text-anchor", "middle")
  .text("Time")

var yAxisLabel = svg.append("text").attr("class", "axis axis-label")
  .attr(
    "transform",
    `translate(${margin.left / 2 - 10},
      ${margin.top + height / 2}) rotate(270)`
  ).style("text-anchor", "middle")
  .text("Tweets per Minute")

var observedLabel = group.append("g")
  .attr(
    "transform",
    `translate(0,${height - 5})`
  )

observedLabel.append("circle")
  .attr("r", 3)
  .style("fill", "steelblue")

observedLabel.append("text")
  .text("observed")
  .attr("transform", "translate(6,0)")
  .style("dominant-baseline", "middle")

var predictedLabel = group.append("g")
.attr(
  "transform",
  `translate(0,${height - 15})`
)

predictedLabel.append("circle")
  .attr("r", 3)
  .style("fill", "firebrick")

predictedLabel.append("text")
  .text("forecast")
  .attr("transform", "translate(6,0)")
  .style("dominant-baseline", "middle")
