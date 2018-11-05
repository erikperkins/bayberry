import {Socket} from "phoenix"
import {Timeseries} from "./timeseries"

export var Tweet = {
  run: function() {
    let socket = new Socket(
      "/twittersocket",
      {params: {token: window.userToken}}
    )
    socket.connect()

    let id = 0
    let channel = socket.channel("twitter:stream", {})

    channel.on("timeseries", payload => {
      Timeseries.update(payload)
    })

    channel.on("tweet", payload => {
      $('#tweet-' + id).fadeOut(100, function() {
        $(this).html(payload.body).fadeIn(100)
      })
      id = (id + 1) % 4
    })

    channel.join()
      .receive("ok", resp => {
        $('#twitter-bird').attr('class', 'fa fa-twitter text-primary')
      }).receive("error", resp => {
        $('#twitter-bird').attr('class', 'fa fa-twitter text-danger')
      })
  }
}
