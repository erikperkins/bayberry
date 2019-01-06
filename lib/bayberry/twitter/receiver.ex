defmodule Bayberry.Twitter.Receiver do
  use GenServer
  require Logger
  import Application, only: [get_env: 2]

  @rabbitmq get_env(:bayberry, Bayberry.Service)[:rabbitmq]
  @twitter get_env(:bayberry, Bayberry.Service)[:twitter]

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    send(self(), :connect)
    {:ok, %{}}
  end

  def handle_info(:connect, state) do
    case @rabbitmq.declare("tweets") do
      {:ok, new} ->
        send(self(), :stream)
        {:noreply, new}

      {:error, :econnrefused} ->
        Process.send_after(self(), :connect, 1000)
        {:noreply, state}
    end
  end

  def handle_info(:stream, state) do
    @twitter.produce(state)
    {:noreply, state}
  end
end
