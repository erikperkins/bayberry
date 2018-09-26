defmodule PhoenixApp.Twitter do
  use GenServer

  require Logger

  @potus "25073877"

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    Logger.warn "Starting worker..."
    state = start_channel()
    # send self(), :work

    send self(), :work
    { :ok, state }
  end

  def handle_info(:work, state) do
    Logger.warn "Starting stream..."
    # spawn(fn -> publish_tweets(state) end)
    publish_tweets(state)
    { :noreply, state }
  end

  def handle_info(:nap, state) do
    Logger.warn "Napping..."
    # spawn(fn -> nap(state) end)
    nap(state)
    { :noreply, state }
  end

  defp nap(_) do
    Process.sleep(5_000)
    Logger.warn "Waking..."

    Process.send_after(self(), :nap, 10)
    #send self(), :nap
  end

  defp start_channel() do
    Logger.warn "Starting channel..."
    url = "amqp://guest:guest@#{System.get_env("RABBITMQ_HOST")}"
    { :ok, connection } = AMQP.Connection.open url
    { :ok, channel } = AMQP.Channel.open connection
    AMQP.Queue.declare channel, "tweets"
    [connection: connection, channel: channel]
  end

  defp publish_tweets(state) do
    Logger.warn "Receiving tweets..."
    for tweet <- ExTwitter.stream_filter([follow: @potus], :infinity) do
      payload = Poison.encode! Map.take(tweet, [:created_at, :text, :lang])
      AMQP.Basic.publish state[:channel], "", "tweets", payload
      # Logger.info "Received tweet"
    end

    Logger.warn("Twitter stream stopped. Restarting stream...")

    # Stop the process instead?
    send self(), :work
  end
end
