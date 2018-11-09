import {Socket} from "phoenix"

export var TweetyBird = {
  run: function() {
    let
      yellow = "#ffc107",
      teal = "#17a2b8",
      green = "#28a745",
      blue = "#007bff",
      red = "#dc3545",
      orange = "darkorange",
      aura = teal,
      queue = []

    let template = [
      '<div class="tweety tooltip" role="tooltip">',
      '<div class="tooltip-inner"></div>',
      '<div class="arrow"></div>',
      '</div>'
    ].join('')

    $('#bird').tooltip({template: template, animation: false})

    let socket = new Socket("/socket", {params: {token: window.userToken}})
    socket.connect()
    let channel = socket.channel("twitter:stream", {})

    channel.join()
      .receive("ok", () => console.log("Joined twitter:stream"))
      .receive("error", () => console.log("Unable to join twitter:stream"))

    channel.on("tweet", () => glow())

    function glow() {
      let now = Date.now()
      queue.push(now)
      queue = queue.filter(a => a > now - 1000)

      d3.select("#bird")
        .style("text-shadow", `0 0 ${4*queue.length}px ${aura}`)
        .style("transition", `text-shadow ${1/queue.length}s ease`)

      let tweets = queue.length == 1 ? "tweet" : "tweets"

      $("#bird").tooltip("hide")
        .attr("data-original-title", `${queue.length} ${tweets} per second`)
        .tooltip("setContent")

      $("#bird").filter(":hover").tooltip("show")
    }
  }
}
