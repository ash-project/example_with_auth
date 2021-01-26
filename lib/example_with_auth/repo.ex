defmodule ExampleWithAuth.Repo do
  use AshPostgres.Repo,
    otp_app: :example_with_auth

  def installed_extensions() do
    ["uuid-ossp", "pg_trgm", "citext"]
  end
end
