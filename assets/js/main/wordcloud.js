export var WordCloud = {
  run: function() {
    d3.json('/word_cloud', function (error, json) {
      if (!error) renderCloud(json);
    });
  }
}

function renderCloud(json) {
  d3.select("#wordcloud").selectAll("text").data([]).exit().remove();

  var colorDomain = [5, 10, 15, 20, 100];
  var colorRange = ["#777", "#666", "#555", "#444", "#333", "#222"];
  var color = d3.scaleLinear().domain(colorDomain).range(colorRange);

  var domain = d3.extent(json, function(d) { return d.size; });
  var size = d3.scaleLog().domain(domain).range([12, 36]);

  var svg = d3.select("#wordcloud").append("g")
    .attr("transform", "translate(100,100)")

  d3.layout.cloud().size([200, 200])
    .timeInterval(10)
    .words(json)
    .rotate(0)
    .fontSize(function(d) { return size(d.size); })
    .padding(1)
    .spiral("archimedean")
    .on("end", draw)
    .start();

  function draw(words) {
    var cloud = svg.selectAll("text").data(words);

    cloud.data(words).enter().append("text")
      .text(function(d) { return d.text; })
      .attr("text-anchor", "middle")
      .style("font-size", function(d) { return d.size + "px"; })
      .style("fill", function(d, i) { return color(i); })
      .transition().duration(500)
      .attr("class", "word")
      .attr("transform", function(d) {
          return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
      });
  }
}
