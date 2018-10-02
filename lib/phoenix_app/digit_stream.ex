defmodule PhoenixApp.DigitStream do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    send self(), :digit
    {:ok, %{}}
  end

  def handle_info(:digit, state) do
    stream_digits()
    {:noreply, state}
  end

  def stream_digits() do
    id = Enum.random(0..10000)
    PhoenixAppWeb.Endpoint.broadcast! "mnist:digit", "digit-stream", PhoenixApp.Mnist.digit(id)

    Process.send_after self(), :digit, 2000
  end
end
