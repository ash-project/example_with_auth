defmodule ExampleWithAuth.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExampleWithAuth.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def user_fixture(attrs \\ %{}) do
    params =
      Enum.into(attrs, %{
        email: unique_user_email(),
        password: valid_user_password()
      })

    ExampleWithAuth.Accounts.User
    |> Ash.Changeset.new()
    |> Ash.Changeset.for_create(:register, params)
    |> ExampleWithAuth.Accounts.Api.create!()
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end
