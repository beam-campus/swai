import Config


config :swai_edge, Edge.Client,
  uri: "wss://swarm-wars.io/edge_socket/websocket",
  reconnect_after_msec: [200, 500, 1_000, 2_000]

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :swai_web, SwaiWeb.Endpoint,
  url: [host: "swai.io", port: 443],
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

# Configures Swoosh API Client
config :swoosh, :api_client, Swai.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
