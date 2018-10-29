defmodule Bayberry.MNIST.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [worker(Bayberry.MNIST.Stream, [], restart: :permanent)]

    opts = [strategy: :one_for_one, name: Bayberry.MNIST.Supervisor]

    case Mix.env() do
      :dev -> Supervisor.init([], opts)
      :test -> Supervisor.init([], opts)
      :prod -> Supervisor.init(children, opts)
    end
  end
end
