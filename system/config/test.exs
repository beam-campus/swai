import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :logatron, Logatron.Repo,
  username: "logatron_dev",
  password: "erlang_t",
  hostname: "localhost",
  database: "logatron_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :logatron_web, LogatronWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "JTn0x9o92aIfICOL2mHTIq+fX5rhnyPZZHZgJ+DxIBiQA2nwKlS05LFPxddqFulL",
  server: false

# Print only warnings and errors during test
config :logger, :console,
level: :debug,
format: "$time[$level]\e[33;44m$metadata\e[0m>> $message\n",
metadata: [:request_id, :initial_call, :mfa]


# In test we don't send emails.
config :logatron, Logatron.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
