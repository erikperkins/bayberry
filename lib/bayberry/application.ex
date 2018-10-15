defmodule Bayberry.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Bayberry.Repo, []),
      # Start the endpoint when the application starts
      supervisor(BayberryWeb.Endpoint, []),
      supervisor(Bayberry.MNIST.Supervisor, []),
      supervisor(Bayberry.Twitter.Supervisor, []),
      supervisor(Bayberry.Timeseries.Supervisor, [])
      # Start your own worker by calling: Bayberry.Worker.start_link(arg1, arg2, arg3)
      # worker(Bayberry.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bayberry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BayberryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
