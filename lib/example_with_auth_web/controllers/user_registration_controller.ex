defmodule ExampleWithAuthWeb.UserRegistrationController do
  use ExampleWithAuthWeb, :controller

  alias ExampleWithAuth.Accounts
  alias ExampleWithAuth.Accounts.User
  alias ExampleWithAuthWeb.UserAuth

  def new(conn, _params) do
    changeset = Ash.Changeset.for_create(User, :register, %{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    Accounts.User
    |> Ash.Changeset.new()
    |> Ash.Changeset.for_create(:register, user_params)
    |> Accounts.Api.create()
    |> case do
      {:ok, user} ->
        user
        |> Ash.Changeset.new()
        |> Ash.Changeset.for_update(:deliver_user_confirmation_instructions, %{
          confirmation_url_fun: &Routes.user_confirmation_url(conn, :confirm, &1)
        })
        |> Accounts.Api.update!()

        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)

      {:error, %{changeset: changeset}} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
