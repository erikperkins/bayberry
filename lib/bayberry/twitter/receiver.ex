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
    {:ok, state} = @rabbitmq.declare("tweets")

    send(self(), :stream)
    {:ok, state}
  end

  def handle_info(:stream, state) do
    @twitter.produce(state)
    {:noreply, state}
  end
end
