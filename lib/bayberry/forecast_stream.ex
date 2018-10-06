defmodule Bayberry.ForecastStream do
  use GenServer
  require Logger
  alias BayberryWeb.Endpoint

  @api Application.get_env(:bayberry, Endpoint)[:timeseries]

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
    spawn fn -> forecast() end
    Process.send_after self(), :timeseries, 500
  end

  defp forecast() do
    case HTTPoison.get("#{@api}") do
      {:ok, %HTTPoison.Response{ body: body }} ->
        spawn fn -> broadcast(body) end
      {:error, %HTTPoison.Error{reason: reason}} -> Logger.error reason
    end
  end

  defp broadcast(body) do
    case Poison.decode(body) do
      {:ok, response} ->
        Endpoint.broadcast("twitter:stream", "timeseries", response || %{})
      _ -> Logger.error "Poison decode error"
    end
  end
end
