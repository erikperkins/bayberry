export var WordCloud = {
  run: function() {
    d3.json('/api/word_cloud', (error, json) => { if (!error) cloud(json) })
  }
}

function cloud(json) {
  d3.select("#wordcloud").selectAll("text").data([]).exit().remove();

  let colorDomain = [5, 10, 15, 20, 100];
  let colorRange = ["#777", "#666", "#555", "#444", "#333", "#222"];
  let color = d3.scaleLinear().domain(colorDomain).range(colorRange);

  let domain = d3.extent(json, function(d) { return d.size; });
  let size = d3.scaleLog().domain(domain).range([12, 36]);

  let svg =
    d3.select("#wordcloud")
    .append("g")
    .attr("transform", "translate(100,100)")

  d3.layout.cloud()
    .size([200, 200])
    .timeInterval(10)
    .words(json)
    .rotate(0)
    .fontSize(function(d) { return size(d.size); })
    .padding(1)
    .spiral("archimedean")
    .on("end", draw)
    .start();

  function draw(words) {
    let cloud =
      svg.selectAll("word")
        .data(words).enter()
        .append("a")
        .attr("class", "word")
        .attr("xlink:href", d => `blog/posts/${d.text}`)
        .attr("transform", d => `translate(${d.x},${d.y})rotate(${d.rotate})`)
        .append("text")
        .text(d => d.text)
        .style("font-size", d => `${d.size}px`)
        .style("fill", (d, i) => color(i))
  }
}
