defmodule PhoenixAppWeb.NlpSocket do
  use Phoenix.Socket

  channel "nlp:*", PhoenixAppWeb.NlpChannel

  transport :websocket, Phoenix.Transports.WebSocket

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end