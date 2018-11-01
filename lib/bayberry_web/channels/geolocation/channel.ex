defmodule BayberryWeb.Geolocation.Channel do
  use Phoenix.Channel
  alias Bayberry.Administration

  def join("geolocation:visitor", _message, socket) do
    {:ok, socket}
  end

  intercept ["stream-visits"]

  def handle_in("stream-visits", _payload, socket) do
    socket
    |> socket_ref()
    |> Administration.stream_visits()

    {:noreply, socket}
  end
end
