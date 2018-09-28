defmodule PhoenixAppWeb.LayoutView do
  use PhoenixAppWeb, :view

  def session_icon(conn) do
    case Plug.Conn.get_session(conn, :current_user) do
      nil -> Phoenix.HTML.raw("<i class='fa fa-sign-in align-text-top'></i>")
      _ -> Phoenix.HTML.raw("<i class='fa fa-sign-out align-text-top'></i>")
    end
  end
end
