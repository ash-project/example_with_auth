defmodule ExampleWithAuthWeb.UserRegistrationController do
  use ExampleWithAuthWeb, :controller

  alias ExampleWithAuth.Accounts
  alias ExampleWithAuth.Accounts.User
  alias ExampleWithAuthWeb.UserAuth

  def new(conn, _params) do
    form = AshPhoenix.Form.for_create(User, :register)

    render(conn, "new.html", form: form)
  end

  def create(conn, %{"user" => user_params}) do
    User
    |> AshPhoenix.Form.for_create(:register, api: ExampleWithAuth.Accounts)
    |> AshPhoenix.Form.validate(user_params)
    |> AshPhoenix.Form.submit()
    |> case do
      {:ok, user} ->
        user
        |> Ash.Changeset.for_update(:deliver_user_confirmation_instructions, %{
          confirmation_url_fun: &Routes.user_confirmation_url(conn, :confirm, &1)
        })
        |> Accounts.update!()

        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)

      {:error, form} ->
        render(conn, "new.html", form: form)
    end
  end
end
