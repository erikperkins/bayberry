defmodule Bayberry.Service.RabbitMQ do
  require Logger
  import Application, only: [get_env: 2]
  alias AMQP.{Basic, Channel, Connection, Queue}

  @retry 5000

  def consume(queue, arguments \\ []) do
    with {:ok, connection} <- Connection.open(url()),
         {:ok, channel} <- Channel.open(connection),
         _ <- Queue.declare(channel, queue, arguments: arguments),
         {:ok, _} <- Basic.consume(channel, queue, nil, no_ack: true) do
      Process.monitor(connection.pid)
      {:ok, channel}
    else
      {:error, error} ->
        Logger.error("Error consuming queue: #{error}")
        Process.sleep(@retry)
        consume(queue, arguments)
    end
  end

  def publish(channel, exchange, queue, payload) do
    Basic.publish(channel, exchange, queue, payload)
  end

  defp url() do
    username = get_env(:bayberry, :rabbitmq)[:username]
    password = get_env(:bayberry, :rabbitmq)[:password]
    host = get_env(:bayberry, :rabbitmq)[:host]
    "amqp://#{username}:#{password}@#{host}"
  end
end
