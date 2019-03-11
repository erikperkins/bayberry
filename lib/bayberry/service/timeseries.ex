defmodule Bayberry.Service.Timeseries do
  require Logger
  import Application, only: [get_env: 2]
  alias BayberryWeb.Endpoint

  def forecast() do
    case HTTPoison.get(get_env(:bayberry, :data_punnet)[:timeseries]) do
      {:ok, %HTTPoison.Response{body: body}} ->
        spawn(fn -> broadcast(body) end)

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(reason)
    end
  end

  defp broadcast(body) do
    case Jason.decode(body) do
      {:ok, response} ->
        Endpoint.broadcast("twitter:stream", "timeseries", response || %{})

      _ ->
        Logger.error("Jason decode error")
    end
  end
end
