defmodule PhoenixApp.TweetProducer do
  use GenServer
  require Logger
  alias PhoenixAppWeb.Endpoint

  @follow "25073877"
  @rabbitmq "amqp://guest:guest@#{Application.get_env(:phoenix_app, Endpoint)[:rabbitmq]}"

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    state = start_channel()

    send self(), :work
    { :ok, state }
  end

  def handle_info(:work, state) do
    publish_tweets(state)
    { :noreply, state }
  end

  defp start_channel() do
    { :ok, connection } = AMQP.Connection.open(@rabbitmq)
    { :ok, channel } = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, "tweets")
    [connection: connection, channel: channel]
  end

  defp publish_tweets(state) do
    for tweet <- ExTwitter.stream_filter([follow: @follow], :infinity) do
      payload = Poison.encode! Map.take(tweet, [:created_at, :text, :lang])

      AMQP.Basic.publish(state[:channel], "", "tweets", payload)
      broadcast(tweet)
    end

    Logger.warn("Twitter stream stopped. Restarting stream...")
    send self(), :work
  end

  defp broadcast(%{text: text}) do
    text
    |> (&Regex.replace(~r/\n|\r/, &1, "\n")).()
    |> (&Regex.replace(~r/(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/, &1, "<a href='\\1' target='_blank'>\\1</a>")).()
    |> (&Endpoint.broadcast("twitter:stream", "tweet", %{body: &1})).()
  end
end
