defmodule Bayberry.Timeseries.Incrementer do
  use GenServer
  require Logger
  import Application, only: [get_env: 2]

  @rabbitmq get_env(:bayberry, Bayberry.Service)[:rabbitmq]
  @timeseries get_env(:bayberry, Bayberry.Service)[:timeseries]

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    @rabbitmq.consume("tweets")
  end

  def handle_info({:basic_consume_ok, _meta}, channel) do
    {:noreply, channel}
  end

  def handle_info({:basic_cancel, _meta}, channel) do
    {:stop, :normal, channel}
  end

  def handle_info({:basic_deliver, payload, _meta}, channel) do
    spawn(fn -> consume(payload, channel) end)
    {:noreply, channel}
  end

  defp consume(payload, _channel) do
    case Poison.decode(payload) do
      {:ok, tweet} -> @timeseries.count(tweet)
      _ -> Logger.error("Could not decode tweet")
    end
  end
end
