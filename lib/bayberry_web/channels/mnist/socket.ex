defmodule BayberryWeb.MNIST.Socket do
  use Phoenix.Socket

  channel "mnist:*", BayberryWeb.MNIST.Channel

  transport :websocket, Phoenix.Transports.WebSocket, check_origin: false

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
