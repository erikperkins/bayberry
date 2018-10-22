defmodule Bayberry.Timeseries.Supervisor do
  use Supervisor

  @redis Application.get_env(:bayberry, BayberryWeb.Endpoint)[:redis]

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Redix,[[host: @redis, port: 6379, database: 3], [name: :redix]]),
      worker(Bayberry.Timeseries.Incrementer, [], restart: :permanent),
      worker(Bayberry.Timeseries.Stream, [], restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Bayberry.Timeseries.Supervisor]
    case Mix.env do
      :dev -> Supervisor.init([], opts)
      :prod -> Supervisor.init(children, opts)
    end
  end
end
