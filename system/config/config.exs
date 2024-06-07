# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :swai_edge, Edge.Client,
  uri: "ws://localhost:4000/edge_socket/websocket",
  reconnect_after_msec: [200, 500, 1_000, 2_000]

# Configure the basic settings of the application
config :swai_core,
  edge_id: "edge_1"

# Configure Mix tasks and generators
config :swai,
  ecto_repos: [Swai.Repo]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :swai, Swai.Mailer, adapter: Swoosh.Adapters.Local

config :swai_web,
  ecto_repos: [Swai.Repo],
  generators: [context_app: :swai, binary_id: true]

# Configures the endpoint
config :swai_web, SwaiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  server: true,
  render_errors: [
    formats: [html: SwaiWeb.ErrorHTML, json: SwaiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Swai.PubSub,
  live_view: [signing_salt: "KEqR3A8v"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  swai_web: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --external:/data/*),
    cd: Path.expand("../apps/swai_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  swai_web: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/swai_web/assets", __DIR__)
  ]


# Configures Elixir's Logger
config :logger, :console,
  format: "$time[$level]\e[33;44m$metadata\e[0m>> $message\n",
  metadata: [:request_id, :initial_call, :mfa]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
