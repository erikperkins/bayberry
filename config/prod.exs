use Mix.Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# BayberryWeb.Endpoint.init/2 when load_from_system_env is
# true. Any dynamic configuration should be done there.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phx.digest task
# which you typically run after static files are built.
config :bayberry, BayberryWeb.Endpoint,
  load_from_system_env: false,
  http: [port: 80, acceptors: 50],
  url: [host: "localhost", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :bayberry, BayberryWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :bayberry, BayberryWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :bayberry, BayberryWeb.Endpoint, server: true
#

# Finally import the config/prod.secret.exs
# which should be versioned separately.
# import_config "prod.secret.exs"

# Configure secret key
config :bayberry, BayberryWeb.Endpoint,
  secret_key_base: System.get_env("BAYBERRY_SECRET_KEY_BASE")

# Configure external API endpoints
config :bayberry, BayberryWeb.Endpoint,
  mnist: "http://mnist.datapun.net/mnist",
  nlp: "http://main.datapun.net:1025/lda",
  timeseries: "http://timeseries.datapun.net/api/forecast",
  rabbitmq: "storage.datapun.net",
  redis: "storage.datapun.net"

# Configure your database
config :bayberry, Bayberry.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("BAYBERRY_USERNAME"),
  password: System.get_env("BAYBERRY_PASSWORD"),
  database: System.get_env("BAYBERRY_DATABASE"),
  hostname: "storage.datapun.net",
  pool_size: 15

config :bayberry, Bayberry.Geolocation,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("BAYBERRY_USERNAME"),
  password: System.get_env("BAYBERRY_PASSWORD"),
  database: "geolocation",
  hostname: "storage.datapun.net",
  timeout: 10000,
  pool_size: 5
