defmodule Bayberry.Service.Timeseries do
  require Logger
  import Application, only: [get_env: 2]
  alias BayberryWeb.Endpoint

  @latest 30

  def forecast() do
    case HTTPoison.get(get_env(:bayberry, :data_punnet)[:timeseries]) do
      {:ok, %HTTPoison.Response{body: body}} ->
        spawn(fn -> broadcast(body) end)

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Cannot retrieve timeseries forecast: #{reason}")
    end
  end

  defp broadcast(body) do
    case Jason.decode(body) do
      {:ok, json} ->
        latest = tail(json, @latest) || %{}
        Endpoint.broadcast("twitter:stream", "timeseries",  latest)

      {:error, error}->
        Logger.error("#{error}: #{body}")
    end
  end

  defp tail(%{"observed" => observed, "predicted" => predicted}, n) do
    %{
      "observed" => sorted_tail(observed, n),
      "predicted" => sorted_tail(predicted, n)
    }
  end

  defp sorted_tail(maps, n) do
    maps
    |> Enum.sort(&(&1["time"] <= &2["time"]))
    |> Enum.take(-n)
  end
end
