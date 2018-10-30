defmodule Bayberry.Timeseries.Stream do
  use GenServer
  import Application, only: [get_env: 2]

  @timeseries get_env(:bayberry, Bayberry.Service)[:timeseries]

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    send(self(), :timeseries)
    {:ok, %{}}
  end

  def handle_info(:timeseries, channel) do
    timeseries()
    {:noreply, channel}
  end

  def timeseries() do
    spawn(fn -> @timeseries.forecast() end)
    Process.send_after(self(), :timeseries, 500)
  end
end
