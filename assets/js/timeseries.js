var
  svg = d3.select("svg").style("background-color", "white"),
  margin = { top: 20, right: 20, bottom: 50, left: 50 },
  width = svg.attr("width") - margin.left - margin.right,
  height = svg.attr("height") - margin.top - margin.bottom,
  g = svg.append("g").attr(
    "transform",
    `translate(${margin.left},${margin.top})`
  );

var
  time = d3.scaleTime().range([0, width]),
  tweets = d3.scaleLinear().range([height, 0]);

let endTime = new Date();
let beginTime = new Date();
beginTime.setMinutes(endTime.getMinutes() - 30);
time.domain([beginTime, endTime]);
tweets.domain([0, 50]);

var parse = function(d) {
  var date = new Date(parseInt(d) * 1000);
  return date;
};

var predictedPath = svg.append("path")
  .attr("class", "timeseries predicted static")
  .attr("transform", `translate(${margin.left},${margin.top})`);

var observedPath = svg.append("path")
  .attr("class", "timeseries observed static")
  .attr("transform", `translate(${margin.left},${margin.top})`);

var predictedNowPath = svg.append("path")
  .attr("class", "timeseries predicted static")
  .attr("transform", `translate(${margin.left},${margin.top})`)
  .attr("stroke-dasharray", "2, 2");

var observedNowPath = svg.append("path")
  .attr("class", "timeseries observed dynamic")
  .attr("transform", `translate(${margin.left},${margin.top})`)
  .attr("stroke-dasharray", "2, 2");

var tAxisLine = svg.append("g").attr("class", "axis")
  .attr(
    "transform",
    `translate(${margin.left},${margin.top + height})`
  );
tAxisLine.call(d3.axisBottom(time).ticks(5));

var yAxisLine = svg.append("g").attr("class", "axis")
  .attr("transform",
   `translate(${margin.left},${margin.top})`
 );
yAxisLine.call(d3.axisLeft(tweets).ticks(5));

var tAxisLabel = svg.append("text").attr("class", "axis axis-label")
  .attr(
    "transform",
    `translate(${margin.left + width / 2},
      ${height + margin.bottom + margin.top / 2})`
  ).style("text-anchor", "middle")
  .text("Time");

var yAxisLabel = svg.append("text").attr("class", "axis axis-label")
  .attr(
    "transform",
    `translate(${margin.left / 2},
      ${margin.top + height / 2}) rotate(270)`
  ).style("text-anchor", "middle")
  .text("Tweets");

svg.append("circle")
  .attr("r", 3)
  .attr(
    "transform",
    `translate(${margin.left + width / 2},${margin.top + height - 30})`
  ).style("fill", "steelblue");

  svg.append("text")
  .attr(
    "transform",
    `translate(${margin.left + width / 2 + 5},${margin.top + height - 30})`
  ).text("observed")
  .style("dominant-baseline", "middle");

  svg.append("circle")
    .attr("r", 3)
    .attr(
      "transform",
      `translate(${margin.left + width / 2},${margin.top + height - 10})`
    ).style("fill", "firebrick");

  svg.append("text")
  .attr(
    "transform",
    `translate(${margin.left + width / 2 + 5},${margin.top + height - 10})`
  ).text("forecast")
  .style("dominant-baseline", "middle")

function timeSeries() {
  var url = 'http://datapun.net/iron/tweets';
  d3.json(url, function (error, json) {
    if (!error) updateTimeSeries(json);
  });
}

function updateTimeSeries(json) {
  let offset = 30;
  let
    [p1, p0, ...p] = d3.entries(json["predicted"])
      .sort((a, b) => parse(a.key) - parse(b.key)).reverse().slice(0, offset),
    predicted = [...p.reverse(), p0],
    predictedNow = [p0, p1];

  let
    [o1, o0, ...o] = d3.entries(json["observed"])
      .sort((a, b) => parse(a.key) - parse(b.key)).reverse().slice(0, offset),
    observed = [...o.reverse(), o0],
    observedNow = [o0, o1];

  let
    all = [...predicted, ...predictedNow, ...observed, ...observedNow],
    max = d3.max(all, d => d.value),
    domain = d3.extent(all, d => parse(d.key)),
    codomain = [0, max];

  time.domain(domain);
  tweets.domain(codomain);

  let line = d3.line()
    .x(d => time(parse(d.key)))
    .y(d => tweets(d.value));

  predictedPath.attr("d", line(predicted));
  observedPath.attr("d", line(observed))
  predictedNowPath.attr("d", line(predictedNow));

  let tAxis = d3.axisBottom(time).ticks(5);
  tAxisLine.call(tAxis).transition(1000);

  let yAxis = d3.axisLeft(tweets).ticks(5);
  yAxisLine.call(yAxis).transition(1000);

  observedNowPath.transition(1000).attr("d", line(observedNow));
}

export {timeSeries};
