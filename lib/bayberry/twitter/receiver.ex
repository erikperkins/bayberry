defmodule Bayberry.Twitter.Receiver do
  use GenServer
  use AMQP
  require Logger
  alias BayberryWeb.Endpoint

  @follow "25073877"
  @rabbitmq "amqp://guest:guest@#{Application.get_env(:bayberry, Endpoint)[:rabbitmq]}"

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    state = start_channel()

    send self(), :stream
    { :ok, state }
  end

  def handle_info(:stream, state) do
    publish_tweets(state)
    { :noreply, state }
  end

  defp start_channel() do
    { :ok, connection } = Connection.open(@rabbitmq)
    { :ok, channel } = Channel.open(connection)
    Queue.declare(channel, "tweets")
    [connection: connection, channel: channel]
  end

  defp publish_tweets(state) do
    Logger.warn("Receiving tweets...")
    filters = [follow: @follow, language: "en"]
    for tweet <- ExTwitter.stream_filter(filters, 10000) do
      tweet
      |> extend_tweet
      |> publish(state)
    end

    Logger.warn("Twitter stream stopped. Restarting stream...")
    send self(), :stream
  end

  defp extend_tweet(tweet) do
    case tweet do
      %{extended_tweet: %{full_text: full_text}} ->
        %{created_at: tweet.created_at, text: full_text}
      _ -> %{created_at: tweet.created_at, text: tweet.text}
    end
  end

  defp publish(tweet, state) do
    case Poison.encode(tweet) do
      {:ok, payload} -> Basic.publish(state[:channel], "", "tweets", payload)
      _ -> Logger.error("Could not encode tweet")
    end
  end
end
