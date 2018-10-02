import {Socket} from "phoenix"
import {updateTimeSeries} from "./timeseries"

export var TwitterSocket = {
  run: function() {
    let socket = new Socket("/twittersocket", {params: {token: window.userToken}})
    socket.connect()

    let id = 0
    let channel = socket.channel("twitter:stream", {})

    channel.on("timeseries", payload => {
      updateTimeSeries(payload)
    })

    channel.on("tweet", payload => {
      let newline = /\n|\r/g
      let url = /(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/ig
      let hashtag = /(#[A-Za-z0-9]+)/g
      let atmention = /(@[A-Za-z0-9]+)/g

      // NOTE: This text processing should be handled on the server
      let tweet = payload.body
        .replace(newline, "\n")
        .replace(url, "<a href='$1' target='_blank'>$1</a>")
        .replace(hashtag, "<strong class='text-primary'>$1</strong>")
        .replace(atmention, "<strong class='text-secondary'>$1</strong>")

      $('#tweet-' + id).fadeOut(100, function() {
        $(this).html(tweet).fadeIn(100)
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
