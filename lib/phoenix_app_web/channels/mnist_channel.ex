defmodule PhoenixAppWeb.MnistChannel do
  use Phoenix.Channel

  def join("mnist:digit", _message, socket) do
    {:ok, socket}
  end

  def join("mnist:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  intercept ["digit-classify"]

  def handle_in("digit-classify", image, socket) do
    {:reply, {:ok, PhoenixApp.Mnist.classify(image)}, socket}
  end
end
