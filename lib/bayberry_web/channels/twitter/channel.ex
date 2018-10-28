defmodule BayberryWeb.Twitter.Channel do
  use Phoenix.Channel

  def join("twitter:stream", _message, socket) do
    {:ok, socket}
  end

  def join("twitter:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  intercept ["transmission"]

  def handle_in("transmission", %{"body" => body}, socket) do
    broadcast!(socket, "transmission", %{body: body})
    {:noreply, socket}
  end

  def handle_out("transmission", payload, socket) do
    push(socket, "transmission", payload)
    {:noreply, socket}
  end
end
