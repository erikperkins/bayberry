import {Socket} from "phoenix"

export var NlpSocket = {
  run: function() {
    let socket = new Socket("/nlpsocket", {params: {token: window.userToken}})
    socket.connect()

    let channel = socket.channel("nlp:lda", {})

    let ldaSearch = document.querySelector("#lda-search")
    let ldaSearchTerm = document.querySelector('#lda-search-term')
    let ldaSearchResults = document.querySelector("#lda-search-results")

    ldaSearch.addEventListener("keypress", event => {
      if (event.keyCode == 13) {
        channel.push("lda-search", {body: ldaSearch.value})
          .receive("ok", payload => {
            ldaSearchTerm.innerText = `${payload.body.slug}`
            ldaSearchResults.innerText = `${payload.body.datum.join(', ')}`
            ldaSearch.value = null
          })
      }
    })

    channel.join()
      .receive("ok", payload => {
        console.log("Joined  nlp:lda successfully")
      }).receive("error", payload => {
        console.log("Unable to join nlp:lda")
      })
  }
}
