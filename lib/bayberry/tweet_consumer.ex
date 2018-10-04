defmodule Bayberry.TweetConsumer do
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
    {:ok, connection} = Connection.open(@rabbitmq)
    {:ok, channel} = Channel.open(connection)
    Queue.declare channel, "tweets"

    {:ok, _} = Basic.consume(channel, "tweets", nil, no_ack: true)
    {:ok, channel}
  end

  def handle_info({:basic_consume_ok, _meta}, channel) do
    {:noreply, channel}
  end

  def handle_info({:basic_cancel, _meta}, channel) do
    {:stop, :normal, channel}
  end

  def handle_info({:basic_deliver, payload, _meta}, channel) do
    spawn fn -> consume(payload, channel) end
    {:noreply, channel}
  end

  defp consume(payload, _channel) do
    case Poison.decode(payload) do
      {:ok, tweet} -> count(tweet)
      _ -> Logger.error("Could not decode outgoing tweet")
    end
  end

  defp count(tweet) do
    {:ok, time} = Timex.parse(tweet["created_at"], @timestamp, :strftime)

    day = %{time | hour: 0, minute: 0, second: 0}
    minute = %{time | second: 0}

    hash = "#{tweet["lang"]}:#{Timex.to_unix day}"
    key = Timex.to_unix(minute)

    case Redix.command(:redix, ~w(hincrby #{hash} #{key} 1)) do
      {:ok, 1} -> expire(hash, day)
      {:ok, _} -> nil
    end
  end

  defp expire(hash, day) do
    expiry = Timex.to_unix(day) + (30 * 24 * 60 * 60)
    Redix.command(:redix, ~w(expireat #{hash} #{expiry}))
  end
end
