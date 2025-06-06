import Config
Code.require_file("./deps/pgpass/lib/pgpass.ex")

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :sample_app, SampleApp.Repo,
  # username: "postgres",
  # password: "postgres",
  username: "dbuser",
  password: Pgpass.find_password("dbuser"),
  database: "sample_app_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sample_app, SampleAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "b+pcal6z4Df2zHr11s7TWmwvAUqO8MbQRzycxPOiD8BVlJ/oMz+BW3IbzB6R+Hb+",
  server: false

# In test we don't send emails.
config :sample_app, SampleApp.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Reduce test times
config :argon2_elixir, t_cost: 1, m_cost: 8
