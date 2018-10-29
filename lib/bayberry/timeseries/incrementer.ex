defmodule Bayberry.Timeseries.Incrementer do
  use GenServer
  use Timex
  use AMQP
  require Logger
  alias BayberryWeb.Endpoint

  @rabbitmq "amqp://guest:guest@#{Application.get_env(:bayberry, Endpoint)[:rabbitmq]}"
  @timestamp "%a %b %d %H:%M:%S %z %Y"

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    with {:ok, connection} <- Connection.open(@rabbitmq),
         {:ok, channel} <- Channel.open(connection),
         _ <- Queue.declare(channel, "tweets"),
         {:ok, _} <- Basic.consume(channel, "tweets", nil, no_ack: true) do
      {:ok, channel}
    else
      {:error, error} -> {:error, error}
    end
  end

  def handle_info({:basic_consume_ok, _meta}, channel) do
    {:noreply, channel}
  end

  def handle_info({:basic_cancel, _meta}, channel) do
    {:stop, :normal, channel}
  end

  def handle_info({:basic_deliver, payload, _meta}, channel) do
    spawn(fn -> consume(payload, channel) end)
    {:noreply, channel}
  end

  defp consume(payload, _channel) do
    case Poison.decode(payload) do
      {:ok, tweet} -> count(tweet)
      _ -> Logger.error("Could not decode tweet")
    end
  end

  defp count(%{"created_at" => created_at}) do
    {:ok, time} = Timex.parse(created_at, @timestamp, :strftime)

    day = %{time | hour: 0, minute: 0, second: 0}
    minute = %{time | second: 0}

    hash = "en:#{Timex.to_unix(day)}"
    key = Timex.to_unix(minute)

    case Redix.command(:redix, ~w(hincrby #{hash} #{key} 1)) do
      {:ok, 1} -> expire(hash, day)
      _ -> nil
    end
  end

  defp expire(hash, day) do
    expiry = Timex.to_unix(day) + 30 * 24 * 60 * 60
    Redix.command(:redix, ~w(expireat #{hash} #{expiry}))
  end
end
