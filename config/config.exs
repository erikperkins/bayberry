# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bayberry,
  ecto_repos: [Bayberry.Repo]

# Configures the endpoint
config :bayberry, BayberryWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "848jxxJwuXulhXM078YPNoxL1QVyz2KrRI5sdByOkiEm5o8x05UEdqTWy9wHUqhT",
  render_errors: [view: BayberryWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bayberry.PubSub, adapter: Phoenix.PubSub.PG2]

# Configure Elixir's Logger
config :logger, :console,
  format: {Bayberry.LogFormatter, :format},
  metadata: [:request_id]

# Configure Twitter API client
config :extwitter, :oauth,
  consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
  consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
  access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
  access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")

config :bayberry, :twitter,
  feed: System.get_env("TWITTER_FEED")

# Configure Cross-Origin Resource Sharing
config :cors_plug,
  origin: "*",
  max_age: 86400,
  methods: ["GET", "POST"]

config :hound,
  driver: "phantomjs",
  browser: "firefox"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
