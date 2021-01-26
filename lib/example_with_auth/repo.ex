defmodule ExampleWithAuth.Repo do
  use Ecto.Repo,
    otp_app: :example_with_auth,
    adapter: Ecto.Adapters.Postgres
end
