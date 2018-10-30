defmodule Bayberry.Timeseries.Supervisor do
  use Supervisor
  import Application, only: [get_env: 2]

  @redis get_env(:bayberry, Bayberry.Service)[:redis]

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      @redis.worker(),
      worker(Bayberry.Timeseries.Incrementer, [], restart: :permanent),
      worker(Bayberry.Timeseries.Stream, [], restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Bayberry.Timeseries.Supervisor]
    Supervisor.init(children, opts)
  end
end
