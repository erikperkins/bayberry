import {Socket} from "phoenix"

export var Classify = {
  run: function() {
    let socket = new Socket("/socket", {params: {token: window.userToken}})
    socket.connect()

    let channel = socket.channel("mnist:digit", {})

    let mnistCanvas = document.querySelector("#mnist-canvas")
    let mnistClear = document.querySelector("#mnist-clear")
    let mnistSubmit = document.querySelector("#mnist-submit")
    let mnistClassification = document.querySelector("#mnist-classification")

    mnistSubmit.addEventListener("click", event => {
      var image = [...mnistCanvas.toDataURL('image/png').split(',')].pop()

      channel.push("digit-classify", {image: image})
        .receive("ok", payload => {
          $("#mnist-submit-icon").removeClass('fa-spin')
          $("#mnist-classification").fadeOut(20, function() {
            $(this).text(payload.classification).fadeIn()
          })
        })
    })

    channel.join()
      .receive("ok", resp => {
        console.log("Joined mnist:digit successfully", resp)
      }).receive("error", resp => {
        console.log("Unable to join mnist:digit", resp)
      })
  }
}
