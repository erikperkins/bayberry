defmodule PhoenixAppWeb.MnistChannel do
  use Phoenix.Channel
  alias PhoenixApp.Mnist

  def join("mnist:digit", _message, socket) do
    {:ok, socket}
  end

  def join("mnist:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  intercept ["digit-classify"]

  def handle_in("digit-classify", image, socket) do
    {:reply, {:ok, Mnist.classify(image)}, socket}
  end
end
