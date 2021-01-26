# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :example_with_auth,
  ecto_repos: [ExampleWithAuth.Repo]

# Configures the endpoint
config :example_with_auth, ExampleWithAuthWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zH+i/4Rk7RXjaeItTjeMzBNAxjhKOJ8kPgGM7a5hx5WtTogcH0KEwJw/Y2pDG2N2",
  render_errors: [view: ExampleWithAuthWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ExampleWithAuth.PubSub,
  live_view: [signing_salt: "e10fhbO+"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :example_with_auth, ExampleWithAuth.Guardian,
  issuer: "example_with_auth",
  secret_key: "P4zZo/H2FayqpKf5jkxTqXNby6CjjR1/aufKqId6mYBc7LgP2c0bV7RZvXaJE2bSHRg=",
  ttl: {3, :days}

config :example_with_auth, ExampleWithAuthWeb.AuthAccessPipeline,
  module: ExampleWithAuth.Guardian,
  error_handler: ExampleWithAuthWeb.AuthErrorHandler

config :example_with_auth, ExampleWithAuth.Mailer,
  adapter: Bamboo.MandrillAdapter,
  api_key: "my_api_key"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
