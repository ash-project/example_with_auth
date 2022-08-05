defmodule ExampleWithAuthWeb.UserSettingsController do
  use ExampleWithAuthWeb, :controller

  alias ExampleWithAuth.Accounts
  alias ExampleWithAuthWeb.UserAuth

  plug :assign_email_and_password_forms

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    params =
      Map.merge(
        params["user"],
        %{
          "update_url_fun" => &Routes.user_settings_url(conn, :confirm_email, &1),
          "current_password" => params["current_password"]
        }
      )

    conn.assigns.current_user
    |> AshPhoenix.Form.for_update(
      :deliver_update_email_instructions,
      api: ExampleWithAuth.Accounts
    )
    |> AshPhoenix.Form.validate(params)
    |> AshPhoenix.Form.submit()
    |> case do
      {:ok, _user} ->
        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, form} ->
        render(conn, "edit.html", email_form: form)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    params =
      Map.merge(
        params["user"],
        %{
          "current_password" => params["current_password"]
        }
      )

    conn.assigns.current_user
    |> AshPhoenix.Form.for_update(
      :change_password,
      api: ExampleWithAuth.Accounts
    )
    |> AshPhoenix.Form.validate(params)
    |> AshPhoenix.Form.submit()
    |> case do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, form} ->
        render(conn, "edit.html", password_form: form)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    conn.assigns.current_user
    |> Ash.Changeset.for_update(:change_email, %{token: token})
    |> ExampleWithAuth.Accounts.update()
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, form} ->
        IO.inspect(form)

        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_forms(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_form, AshPhoenix.Form.for_update(user, :change_email))
    |> assign(:password_form, AshPhoenix.Form.for_update(user, :change_password))
  end
end
