defmodule Bayberry.MNIST.Stream do
  use GenServer
  import Application, only: [get_env: 2]
  alias BayberryWeb.Endpoint

  @classifier get_env(:bayberry, Bayberry.Service)[:mnist]

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    send(self(), :digit)
    {:ok, %{}}
  end

  def handle_info(:digit, state) do
    stream_digits()
    {:noreply, state}
  end

  def stream_digits() do
    id = Enum.random(0..10000)
    Endpoint.broadcast("mnist:digit", "digit-stream", @classifier.digit(id) || %{})

    Process.send_after self(), :digit, 2000
  end
end
