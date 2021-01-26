defmodule ExampleWithAuth.Accounts.User.Validations do
  alias ExampleWithAuth.Accounts.User.Validations

  def validate_current_password() do
    {Validations.ValidateCurrentPassword, []}
  end
end
