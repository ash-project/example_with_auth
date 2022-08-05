defmodule ExampleWithAuth.MixProject do
  use Mix.Project

  def project do
    [
      app: :example_with_auth,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExampleWithAuth.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # {:ash, github: "ash-project/ash", override: true},
      {:ash, path: "../ash", override: true},
      {:ash_postgres, github: "ash-project/ash_postgres"},
      {:ash_phoenix, github: "ash-project/ash_phoenix"},

      # Absinthe for GraphQL
      {:absinthe, "~> 1.5.0"},
      {:absinthe_plug, "~> 1.5.0"},

      # Bamboo for Emailing
      {:bamboo, "~> 1.5"},
      {:premailex, "~> 0.3.0"},
      {:floki, ">= 0.0.0"},
      {:guardian, "~> 2.0"},
      {:bcrypt_elixir, "~> 3.0"},
      {:sobelow, "~> 0.8", only: :dev},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:phoenix, "~> 1.5.7"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.8"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.15.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["ash_postgres.create", "ash_postgres.migrate", "run priv/repo/seeds.exs"],
      reset: ["ash_postgres.drop", "ash_postgres.setup"]
    ]
  end
end
