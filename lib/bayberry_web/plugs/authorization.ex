defmodule BayberryWeb.Plugs.Authorization do
  import Plug.Conn, only: [get_session: 2, put_session: 3, assign: 3, halt: 1]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def init(_params) do
  end

  def call(conn, _params) do
    case get_session(conn, :user_id) do
      nil ->
        conn
        |> put_session(:redirect_url, conn.request_path)
        |> put_flash(:error, "Login required")
        |> redirect(to: "/sessions/new")
        |> halt()

      user_id ->
        assign(conn, :current_user, Bayberry.Accounts.get_user!(user_id))
    end
  end
end
