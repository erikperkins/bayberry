// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {})

channel.on("tweet", payload => {
  let id = Math.floor(Math.random() * 3)

  let newline = /\n|\r/g
  let url = /(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/ig
  let hashtag = /(#[A-Za-z0-9]+)/g
  let atmention = /(@[A-Za-z0-9]+)/g

  let tweet = payload.body
    .replace(newline, "\n")
    .replace(url, "<a href='$1' target='_blank'>$1</a>")
    .replace(hashtag, "<strong class='text-primary'>$1</strong>")
    .replace(atmention, "<strong class='text-secondary'>$1</strong>")

  $('#tweet-' + id).fadeOut(100, function() {
    $(this).html(tweet).fadeIn(100)
  })
})

channel.join()
  .receive("ok", resp => {
    $('#twitter-bird').attr('class', 'fa fa-twitter text-primary')
  }).receive("error", resp => {
    $('#twitter-bird').attr('class', 'fa fa-twitter text-danger')
  })

export default socket
