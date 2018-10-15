defmodule BayberryWeb.NLP.Socket do
  use Phoenix.Socket

  channel "nlp:*", BayberryWeb.NLP.Channel

  transport :websocket, Phoenix.Transports.WebSocket, check_origin: false

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
