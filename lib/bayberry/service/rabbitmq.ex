defmodule Bayberry.Service.RabbitMQ do
  alias AMQP.{Basic, Channel, Connection, Queue}

  @url "amqp://guest:guest@storage.datapun.net"

  def declare(queue) do
    with {:ok, connection} <- Connection.open(@url),
         {:ok, channel} <- Channel.open(connection),
         _ <- Queue.declare(channel, queue) do
      {:ok, %{channel: channel}}
    else
      {:error, error} -> {:error, error}
    end
  end

  def consume(queue) do
    with {:ok, connection} <- Connection.open(@url),
         {:ok, channel} <- Channel.open(connection),
         _ <- Queue.declare(channel, queue),
         {:ok, _} <- Basic.consume(channel, queue, nil, no_ack: true) do
      {:ok, channel}
    else
      {:error, error} -> {:error, error}
    end
  end

  def publish(channel, exchange, queue, payload) do
    Basic.publish(channel, exchange, queue, payload)
  end
end
