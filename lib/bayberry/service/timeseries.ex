defmodule Bayberry.Service.Timeseries do
  require Logger
  import Application, only: [get_env: 2]
  alias BayberryWeb.Endpoint

  @redis get_env(:bayberry, Bayberry.Service)[:redis]

  def count(%{"created_at" => created_at}) do
    timestamp = "%a %b %d %H:%M:%S %z %Y"
    {:ok, time} = Timex.parse(created_at, timestamp, :strftime)

    day = %{time | hour: 0, minute: 0, second: 0}
    minute = %{time | second: 0}

    hash = "en:#{Timex.to_unix(day)}"
    key = Timex.to_unix(minute)

    case @redis.command(:redix, ~w(hincrby #{hash} #{key} 1)) do
      {:ok, 1} -> expire(hash, day)
      _ -> nil
    end
  end

  def forecast() do
    case HTTPoison.get("http://timeseries.datapun.net/api/forecast") do
      {:ok, %HTTPoison.Response{body: body}} ->
        spawn(fn -> broadcast(body) end)

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(reason)
    end
  end

  defp broadcast(body) do
    case Poison.decode(body) do
      {:ok, response} ->
        Endpoint.broadcast("twitter:stream", "timeseries", response || %{})

      _ ->
        Logger.error("Poison decode error")
    end
  end

  defp expire(hash, day) do
    expiry = Timex.to_unix(day) + 30 * 24 * 60 * 60
    @redis.command(:redix, ~w(expireat #{hash} #{expiry}))
  end
end
