defmodule ExampleWithAuthWeb.UserResetPasswordController do
  use ExampleWithAuthWeb, :controller

  alias ExampleWithAuth.Accounts

  plug :get_user_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    if user = Accounts.Api.get(Accounts.User, email: email) do
      user
      |> Ash.Changeset.new()
      |> Ash.Changeset.for_update(:deliver_user_reset_password_instructions,
        reset_password_url_fun: &Routes.user_reset_password_url(conn, :edit, &1)
      )
      |> Accounts.Api.update!()
    end

    # Regardless of the outcome, show an impartial success/error message.
    conn
    |> put_flash(
      :info,
      "If your email is in our system, you will receive instructions to reset your password shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, _params) do
    render(conn, "edit.html",
      changeset: Ash.Changeset.for_update(conn.assigns.user, :change_password, %{})
    )
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def update(conn, %{"user" => user_params}) do
    conn.assigns.user
    |> Ash.Changeset.new()
    |> Ash.Changeset.for_update(:change_password, user_params)
    |> Accounts.Api.update()
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: Routes.user_session_path(conn, :new))

      {:error, %{changeset: changeset}} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  defp get_user_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    user =
      Accounts.User
      |> Ash.Query.for_read(:by_token, token: token, context: "reset_password")
      |> Accounts.Api.read_one!()

    if user do
      conn |> assign(:user, user) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
