defmodule ExampleWithAuth.Accounts.Registry do
  use Ash.Registry,
    extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry ExampleWithAuth.Accounts.User
    entry ExampleWithAuth.Accounts.UserToken
  end
end
