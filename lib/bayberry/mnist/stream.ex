defmodule Bayberry.MNIST.Stream do
  use GenServer
  import Application, only: [get_env: 2]
  alias BayberryWeb.Endpoint

  @mnist get_env(:bayberry, Bayberry.Service)[:mnist]

  def start_link(%{}) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    for _ <- 1..@mnist.threads do
      send(self(), :digit)
    end

    {:ok, %{}}
  end

  def handle_info(:digit, state) do
    spawn(fn -> digit() end)
    {:noreply, state}
  end

  defp digit() do
    Enum.random(0..10000)
    |> @mnist.digit()
    |> (&Endpoint.broadcast("mnist:stream", "digit", &1)).()

    case GenServer.whereis(__MODULE__) do
      nil -> nil
      pid -> send(pid, :digit)
    end
  end
end
