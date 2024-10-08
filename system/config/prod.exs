import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: GithubProxy.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

config :swai, Swai.Repo,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  hostname: "postgres",
  database: System.get_env("POSTGRES_DB"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :swai_edge, Edge.Client,
  uri: "wss://swarm-wars.ai/edge_socket/websocket",
  reconnect_after_msec: [200, 500, 1_000, 2_000]

config :swai_train_swarm, TrainSwarmProc.CommandedApp,
  event_store: [
    adapter: Commanded.EventStore.Adapters.Extreme,
    serializer: Commanded.Serialization.JsonSerializer,
    stream_prefix: "train_swarm",
    extreme: [
      db_type: :node,
      host: "eventstore",
      port: 1113,
      username: "admin",
      password: "changeit",
      reconnect_delay: 2_000,
      max_attempts: :infinity
    ]
  ],
  pubsub: :local,
  registry: :local

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :swai_web, SwaiWeb.Endpoint,
  url: [host: "swarm-wars.ai", port: 443],
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

# Configures Swoosh API Client
config :swoosh, :api_client, Swai.Finch

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

# config :swai, Swai.Mailer,
#   adapter: Swoosh.Adapters.SMTP,
#   relay: System.get_env("SWAI_SMTP_RELAY"),
#   username: System.get_env("SWAI_SMTP_USERNAME"),
#   password: System.get_env("SWAI_SMTP_PASSWORD"),
#   port: String.to_integer(System.get_env("SWAI_SMTP_PORT") || "587"),
#   tls: :always,
#   auth: :always,
#   ssl: true,
#   # dkim: [
#   #   d: System.get_env("SWAI_SMTP_DKIM_DOMAIN"),
#   #   s: System.get_env("SWAI_SMTP_DKIM_SELECTOR"),
#   #   private_key: System.get_env("SWAI_SMTP_DKIM_PRIVATE_KEY")
#   # ],
#   retries: 3,
#   no_mx_lookups: false
