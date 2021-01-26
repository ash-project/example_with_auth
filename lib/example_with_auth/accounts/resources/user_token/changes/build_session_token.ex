defmodule ExampleWithAuth.Accounts.UserToken.Changes.BuildSessionToken do
  @moduledoc "A change that sets the session token based on the user id"

  use Ash.Resource.Change
  @rand_size 32

  def build_session_token() do
    {__MODULE__, []}
  end

  def change(changeset, _opts, _context) do
    token = :crypto.strong_rand_bytes(@rand_size)

    Ash.Changeset.change_attribute(changeset, :token, token)
  end
end
