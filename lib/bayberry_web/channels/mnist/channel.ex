defmodule BayberryWeb.MNIST.Channel do
  use Phoenix.Channel
  import Application, only: [get_env: 2]
  alias Bayberry.Presence

  @mnist get_env(:bayberry, Bayberry.Service)[:mnist]

  def join("mnist:digit", _message, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def join("mnist:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(:after_join, socket) do
    if count(Presence.list(socket)) == 0 do
      Bayberry.MNIST.Supervisor.start_stream()
    end

    {:ok, _} = Presence.track(socket, socket.join_ref, %{})

    {:noreply, socket}
  end

  intercept ["digit-classify", "digits"]

  def handle_in("digit-classify", image, socket) do
    {:reply, {:ok, @mnist.classify(image)}, socket}
  end

  def handle_in("digits", _payload, socket) do
    {:reply, {:digits, %{digits: @mnist.digits()}}, socket}
  end

  def terminate({:shutdown, :closed}, socket) do
    if count(Presence.list(socket)) == 1 do
      Bayberry.MNIST.Supervisor.stop_stream()
    end
  end

  defp count(presence) do
    Enum.reduce(presence, 0, fn {_, v}, sum -> sum + length(v.metas) end)
  end
end
