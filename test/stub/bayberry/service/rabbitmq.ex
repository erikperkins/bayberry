defmodule Stub.Bayberry.Service.RabbitMQ do
  alias AMQP.Channel

  def declare(_queue) do
    state = %{channel: %Channel{}}
    {:ok, state}
  end

  def consume(_queue) do
    {:ok, %Channel{}}
  end

  def publish(_channel, _exchange, _queue, payload) do
    message = {:basic_deliver, payload, %{}}
    Process.send(Bayberry.Twitter.Stream, message, [])
    Process.send(Bayberry.Timeseries.Incrementer, message, [])
  end
end
