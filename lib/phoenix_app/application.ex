defmodule PhoenixApp.Application do
  use Application

  @redis Application.get_env(:phoenix_app, PhoenixAppWeb.Endpoint)[:redis]

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(PhoenixApp.Repo, []),
      # Start the endpoint when the application starts
      supervisor(PhoenixAppWeb.Endpoint, []),
      # Start your own worker by calling: PhoenixApp.Worker.start_link(arg1, arg2, arg3)
      # worker(PhoenixApp.Worker, [arg1, arg2, arg3]),
      worker(
        Redix,
        [
          [host: @redis, port: 6379, database: 3],
          [name: :redix]
        ]
      ),
      worker(PhoenixApp.MnistStream, [], restart: :permanent),
      worker(PhoenixApp.TweetConsumer, [], restart: :permanent),
      worker(PhoenixApp.TweetProducer, [], restart: :permanent),
      worker(PhoenixApp.ForecastStream, [], restart: :permanent)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PhoenixAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
