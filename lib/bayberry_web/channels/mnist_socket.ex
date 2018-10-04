defmodule BayberryWeb.MnistSocket do
  use Phoenix.Socket

  channel "mnist:*", BayberryWeb.MnistChannel

  transport :websocket, Phoenix.Transports.WebSocket, check_origin: false

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
