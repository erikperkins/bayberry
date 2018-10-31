defmodule BayberryWeb.MNIST.Channel do
  use Phoenix.Channel
  import Application, only: [get_env: 2]

  @classifier get_env(:bayberry, Bayberry.Service)[:mnist]

  def join("mnist:digit", _message, socket) do
    {:ok, socket}
  end

  def join("mnist:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  intercept ["digit-classify"]

  def handle_in("digit-classify", image, socket) do
    {:reply, {:ok, @classifier.classify(image)}, socket}
  end
end
