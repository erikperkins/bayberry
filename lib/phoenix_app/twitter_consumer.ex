defmodule PhoenixApp.TwitterConsumer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    { :ok, state }
  end

  def handle_info(:work, state) do
    rabbitmq = System.get_env("RABBITMQ_HOST")
    { :ok, connection } = AMQP.Connection.open "amqp://guest:guest@#{rabbitmq}"
    { :ok, channel } = AMQP.Channel.open connection

    AMQP.Queue.declare channel, "tweets"

    pid = spawn(fn ->
      cnn = "759251"
      stream = ExTwitter.stream_filter [follow: cnn], :infinity
      for tweet <- stream do
        point = Poison.encode! Map.take(tweet, [:created_at, :text, :lang])

        AMQP.Basic.publish channel, "", "tweets", point
      end
    end)

    { :noreply, state }
  end

  def schedule_work do
    delay = 40
    Process.send_after(self(), :work, delay)
  end
end
