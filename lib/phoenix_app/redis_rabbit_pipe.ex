defmodule PhoenixApp.RedisRabbitPipe do
  use GenServer

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
    AMQP.Queue.declare channel, "data"
    AMQP.Basic.consume channel, "data", nil, no_ack: true

    # { :ok, connection } = Redix.start_link "redis://redis:6379/3", :pipe
    # Redis.stop connection
    wait_for_messages()
  end

  def wait_for_messages do
    receive do
      { :basic_deliver, payload, _meta } ->
        { :ok, message } = Poison.decode payload
        { :ok, minute } = nearest_minute message["created_at"]
        { :ok, _ } = Redix.command :redix, ~w(hincrby #{minute} #{message["lang"]} 1)
        { :ok, _ } = Redix.command :redix, ~w(expire #{minute} 86400)

        PhoenixApp.Endpoint.broadcast! "room:lobby", "tweet",
          %{ body: message["text"] }

        wait_for_messages()
    end
  end

  def nearest_minute timestamp do
    twitter_format = "%a %b %d %H:%M:%S %z %Y"
    { :ok, time } = Timex.parse timestamp, twitter_format, :strftime
    time = %{ time | second: 0 }
    redis_format = "%Y-%m-%dT%H:%M:%S%z"
    Timex.format time, redis_format, :strftime
  end

end
