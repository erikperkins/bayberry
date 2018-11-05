defmodule BayberryWeb.Socket do
  use Phoenix.Socket

  channel "geolocation:*", BayberryWeb.Geolocation.Channel
  channel "mnist:*", BayberryWeb.MNIST.Channel
  channel "nlp:*", BayberryWeb.NLP.Channel
  channel "twitter:*", BayberryWeb.Twitter.Channel

  transport :websocket, Phoenix.Transports.WebSocket, check_origin: false

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
