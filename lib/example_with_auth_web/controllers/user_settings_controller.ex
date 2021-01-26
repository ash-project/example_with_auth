defmodule ExampleWithAuthWeb.UserSettingsController do
  use ExampleWithAuthWeb, :controller

  alias ExampleWithAuth.Accounts
  alias ExampleWithAuthWeb.UserAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    conn.assigns.current_user
    |> Ash.Changeset.new()
    |> Ash.Changeset.set_argument(
      :update_url_fun,
      &Routes.user_settings_url(conn, :confirm_email, &1)
    )
    |> Ash.Changeset.set_argument(:current_password, params["current_password"])
    |> Ash.Changeset.for_update(
      :deliver_update_email_instructions,
      params["user"]
    )
    |> Accounts.Api.update()
    |> case do
      {:ok, _user} ->
        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, %{changeset: changeset}} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    conn.assigns.current_user
    |> Ash.Changeset.new()
    |> Ash.Changeset.set_argument(:current_password, params["current_password"])
    |> Ash.Changeset.for_update(:change_password, params["user"])
    |> Accounts.Api.update()
    |> case do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, %{changeset: changeset}} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    conn.assigns.current_user
    |> Ash.Changeset.new()
    |> Ash.Changeset.for_update(:change_email, %{token: token})
    |> ExampleWithAuth.Accounts.Api.update()
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, _} ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_changeset, Ash.Changeset.for_update(user, :change_email, %{}))
    |> assign(:password_changeset, Ash.Changeset.for_update(user, :change_passowrd, %{}))
  end
end
