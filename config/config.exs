# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phoenix_app,
  ecto_repos: [PhoenixApp.Repo]

# Configures the endpoint
config :phoenix_app, PhoenixAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "848jxxJwuXulhXM078YPNoxL1QVyz2KrRI5sdByOkiEm5o8x05UEdqTWy9wHUqhT",
  render_errors: [view: PhoenixAppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixApp.PubSub, adapter: Phoenix.PubSub.PG2]

# Configure external API endpoints
config :phoenix_app, PhoenixAppWeb.Endpoint,
  mnist: "http://mnist.datapun.net/mnist",
  nlp: "http://main.datapun.net:1025/lda",
  rabbitmq: "storage.datapun.net",
  redis: "storage.datapun.net",
  timeseries: "http://timeseries.datapun.net:8003"

# Configure Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure Twitter API client
config :extwitter, :oauth, [
   consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
   consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
   access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
   access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")
]

# Configure Cross-Origin Resource Sharing
config :cors_plug,
  origin: "*",
  max_age: 86400,
  methods: ["GET", "POST"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
