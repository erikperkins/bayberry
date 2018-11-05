import {Socket} from "phoenix"

export var Stream = {
  run: function() {
    let socket = new Socket("/mnistsocket", {params: {token: window.userToken}})
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
          $("#mnist-classification").fadeOut(250, function() {
            $(this).text(payload.classification).fadeIn()
          })
        })
    })

    channel.on("digit-stream", payload => {
      $("#mnist-image").fadeOut(500, function() {
        $(this).attr("xlink:href", `data:image/png;base64,${payload.image}`)
          .fadeIn()
      })

      $("#mnist-digit").fadeOut(500, function() {
        $(this).text(payload.classification).fadeIn()
      })
    })

    channel.join()
      .receive("ok", resp => {
        document.getElementById("mnist-equals").style['fill'] = "black"
        console.log("Joined mnist:digit successfully", resp)
      }).receive("error", resp => {
        console.log("Unable to join mnist:digit", resp)
      })
  }
}
