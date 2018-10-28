defmodule BayberryWeb.SessionController do
  use BayberryWeb, :controller

  alias Bayberry.Accounts

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Accounts.authenticate_by_email_password(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:success, "Signed in")
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: get_session(conn, :redirect_url) || "/")

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: session_path(conn, :new))
    end
  end

  def update(conn, params) do
    case get_session(conn, :user_id) do
      nil -> new(conn, params)
      _ -> delete(conn, params)
    end
  end

  def delete(conn, _) do
    conn
    |> clear_session
    |> put_flash(:warning, "Signed out")
    |> redirect(to: "/")
  end
end
