defmodule Bayberry.Twitter.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Bayberry.Twitter.Stream, [], restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Bayberry.Twitter.Supervisor]
    Supervisor.init(children, opts)
  end
end
