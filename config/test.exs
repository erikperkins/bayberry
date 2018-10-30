use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bayberry, BayberryWeb.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :bayberry, Bayberry.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "test",
  password: "test",
  database: "bayberry_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :bayberry, Bayberry.Geolocation,
  adapter: Ecto.Adapters.Postgres,
  username: "test",
  password: "test",
  database: "bayberry_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :bayberry, BayberryWeb.Plugs,
  authorization: Stub.BayberryWeb.Plugs.Authorization,
  geolocation: Stub.BayberryWeb.Plugs.Geolocation

config :bayberry, Bayberry.Service,
  mnist: Stub.Bayberry.Service.MNIST,
  nlp: Stub.Bayberry.Service.NLP
