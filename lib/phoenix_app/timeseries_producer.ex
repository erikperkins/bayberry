defmodule PhoenixApp.TimeseriesProducer do
  use GenServer
  use Timex

  @twitter_format "%a %b %d %H:%M:%S %z %Y"

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    { :ok, state }
  end

  def handle_info(:work, state) do
    listen()
    { :noreply, state }
  end

  def schedule_work do
    delay = 1 * 1000
    Process.send_after(self(), :work, delay)
  end

  def listen do
    rabbitmq = System.get_env("RABBITMQ_HOST")
    { :ok, connection } = AMQP.Connection.open "amqp://guest:guest@#{rabbitmq}"
    { :ok, channel } = AMQP.Channel.open connection
    AMQP.Queue.declare channel, "tweets"
    AMQP.Basic.consume channel, "tweets", nil, no_ack: true

    wait_for_messages()
  end

  def wait_for_messages do
    receive do
      { :basic_deliver, payload, _meta } ->
        { :ok, tweet } = Poison.decode payload

        count_tweet tweet

        PhoenixAppWeb.Endpoint.broadcast! "room:lobby", "tweet",
          %{ body: tweet["text"] }

        wait_for_messages()
    end
  end

  def count_tweet tweet do
    { :ok, time } = Timex.parse tweet["created_at"], @twitter_format, :strftime

    day = %{ time | hour: 0, minute: 0, second: 0 }
    minute = %{ time | second: 0 }

    hash = "#{tweet["lang"]}:#{Timex.to_unix day}"
    key = Timex.to_unix minute

    { :ok, reply } = Redix.command :redix, ~w(hincrby #{hash} #{key} 1)

    if reply == 1 do
      expiry = Timex.to_unix(day) + (30 * 24 * 60 * 60)
      { :ok, _ } = Redix.command :redix, ~w(expireat #{hash} #{expiry})
    end
  end
end
