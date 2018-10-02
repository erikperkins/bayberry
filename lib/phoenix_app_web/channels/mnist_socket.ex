defmodule PhoenixAppWeb.MnistSocket do
  use Phoenix.Socket

  channel "mnist:*", PhoenixAppWeb.MnistChannel

  transport :websocket, Phoenix.Transports.WebSocket

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
