$(document).on('turbolinks:load', function() {
  if (window.location.pathname == '/mnist/index') {
    digitCanvas();
  }
})

function digitCanvas() {
  var ctx = d3.select('#mnist-canvas').node().getContext('2d');
  var x0, y0;

  d3.select('#mnist-clear')
    .on('click', clearDigit);

  d3.select('#mnist-submit')
    .on('click', function() { $('#mnist-submit-icon').addClass('fa-spin'); })

  d3.select('#mnist-canvas').on('mousedown touchstart', function() {
    var canvas = d3.select(this).classed('active', true);

    var frame = d3.select(window)
      .on('mousemove touchmove', mousemove)
      .on('mouseup touchend', mouseup)
      .on('mouseout touchcancel', mouseout);

    // [x0, y0] = d3.mouse(canvas.node());
    x0 = d3.mouse(canvas.node())[0];
    y0 = d3.mouse(canvas.node())[1];
    drawDigit(x0, y0);

    d3.event.preventDefault();

    function mousemove() {
      // var [x, y] = d3.mouse(canvas.node());
      var x = d3.mouse(canvas.node())[0];
      var y = d3.mouse(canvas.node())[1];
      drawDigit(x, y);
    }

    function mouseup() {
      x0 = undefined;
      y0 = undefined;
      canvas.classed('active', false);
      frame.on('mousemove', null).on('mouseup', null);
    }

    function mouseout() {
      x0 = undefined;
      y0 = undefined;
      canvas.classed('active', false);
      frame.on('mousemove', null).on('mouseup', null);
    }

    function drawDigit(x, y) {
      ctx.beginPath();
      ctx.strokeStyle = 'black';
      ctx.lineWidth = 16;
      ctx.lineJoin = 'round';
      ctx.moveTo(x0, y0);
      ctx.lineTo(x, y);
      ctx.closePath();
      ctx.stroke();
      // [x0, y0] = [x, y];
      x0 = x;
      y0 = y;
    }
  });

  function clearDigit() {
    x0 = undefined;
    y0 = undefined;
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    $('#mnist-classification-new').text('?')
  }

}
