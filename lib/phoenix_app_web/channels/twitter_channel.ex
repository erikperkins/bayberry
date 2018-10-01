defmodule PhoenixAppWeb.TwitterChannel do
  use Phoenix.Channel

  def join("twitter:stream", _message, socket) do
    { :ok, socket }
  end

  def join("twitter:" <> _private_room_id, _params, _socket) do
    { :error, %{ reason: "unauthorized" } }
  end

  intercept ["new_msg"]

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast! socket, "new_msg", %{body: body}
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

end
