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
    case Enum.random(1..9999) |> @mnist.digit() do
      :error -> nil
      response -> Endpoint.broadcast("mnist:stream", "digit", response)
    end

    case GenServer.whereis(__MODULE__) do
      nil -> nil
      pid -> send(pid, :digit)
    end
  end
end
