defmodule Bayberry.Service.RabbitMQ do
  import Application, only: [get_env: 2]
  alias AMQP.{Basic, Channel, Connection, Queue}

  def declare(queue) do
    with {:ok, connection} <- Connection.open(url()),
         {:ok, channel} <- Channel.open(connection),
         _ <- Queue.declare(channel, queue) do
      {:ok, %{channel: channel}}
    else
      {:error, error} -> {:error, error}
    end
  end

  def consume(queue) do
    with {:ok, connection} <- Connection.open(url()),
         {:ok, channel} <- Channel.open(connection),
         _ <- Queue.declare(channel, queue),
         {:ok, _} <- Basic.consume(channel, queue, nil, no_ack: true) do
      {:ok, channel}
    else
      {:error, error} -> {:error, error}
    end
  end

  def publish(channel, exchange, queue, payload) do
    Basic.publish(channel, exchange, queue, payload, expiration: 5000)
  end

  defp url() do
    username = get_env(:bayberry, :rabbitmq)[:username]
    password = get_env(:bayberry, :rabbitmq)[:password]
    host = get_env(:bayberry, :rabbitmq)[:host]
    "amqp://#{username}:#{password}@#{host}"
  end
end
