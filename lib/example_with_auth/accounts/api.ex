defmodule ExampleWithAuth.Accounts.Api do
  use Ash.Api

  resources do
    resource ExampleWithAuth.Accounts.User
    resource ExampleWithAuth.Accounts.UserToken
  end
end
