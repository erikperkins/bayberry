defmodule Bayberry.Twitter.Stream do
  use GenServer
  use AMQP
  require Logger
  alias BayberryWeb.Endpoint

  @rabbitmq "amqp://guest:guest@#{Application.get_env(:bayberry, Endpoint)[:rabbitmq]}"

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    with {:ok, connection} <- Connection.open(@rabbitmq),
         {:ok, channel} <- Channel.open(connection),
         _ <- Queue.declare(channel, "tweets"),
         {:ok, _} <- Basic.consume(channel, "tweets", nil, no_ack: true) do
      {:ok, channel}
    else
      {:error, error} -> {:error, error}
    end
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
      {:ok, tweet} -> spawn(fn -> broadcast(tweet) end)
      _ -> Logger.error("Could not decode tweet")
    end
  end

  defp broadcast(%{"text" => text}) do
    link = ~r/(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/

    text
    |> (&Regex.replace(~r/\n|\r/, &1, "\n")).()
    |> (&Regex.replace(link, &1, "<a href='\\1' target='_blank'>\\1</a>")).()
    |> (&Endpoint.broadcast("twitter:stream", "tweet", %{body: &1} || %{})).()
  end
end
