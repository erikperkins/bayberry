defmodule BayberryWeb.MNIST.Channel do
  use Phoenix.Channel
  alias Bayberry.MNIST.Classifier

  def join("mnist:digit", _message, socket) do
    {:ok, socket}
  end

  def join("mnist:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  intercept ["digit-classify"]

  def handle_in("digit-classify", image, socket) do
    {:reply, {:ok, Classifier.classify(image)}, socket}
  end
end
