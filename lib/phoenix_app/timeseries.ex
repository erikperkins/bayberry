defmodule PhoenixApp.TimeSeries do
  use GenServer

  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    send self(), :timeseries
    {:ok, %{}}
  end

  def handle_info(:timeseries, state) do
    timeseries()
    {:noreply, state}
  end

  def timeseries() do
    case HTTPoison.get("http://timeseries.datapun.net:8003") do
      {:ok, %HTTPoison.Response{ body: body }} ->
        response = Poison.decode!(body)
        PhoenixAppWeb.Endpoint.broadcast!("twitter:stream", "timeseries", response)
      {:error, %HTTPoison.Error{reason: reason}} -> Logger.warn reason
    end

    Process.send_after self(), :timeseries, 500
  end
end
