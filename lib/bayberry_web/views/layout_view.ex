defmodule BayberryWeb.LayoutView do
  use BayberryWeb, :view

  alias Phoenix.HTML

  def session_icon(conn) do
    case Plug.Conn.get_session(conn, :user_id) do
      nil ->
        link to: session_path(conn, :update), method: :patch,
          class: "lead text-default navbar-brand" do
            HTML.raw("<i class='fa fa-sign-in text-success'></i>")
          end
      _ ->
      link to: session_path(conn, :update), method: :patch,
        class: "lead text-default navbar-brand" do
          HTML.raw("<i class='fa fa-sign-out text-warning'></i>")
        end
    end
  end

  def user_icon(conn) do
    case Plug.Conn.get_session(conn, :user_id) do
      nil -> nil
      user_id ->
        link to: accounts_user_path(conn, :show, user_id),
          class: "lead text-default navbar-brand" do
            HTML.raw("<i class='fa fa-user-circle-o text-info'></i>")
          end
    end
  end

  def administration_icon(conn) do
    case Plug.Conn.get_session(conn, :user_id) do
      nil -> nil
      _ ->
        link to: administration_path(conn, :index),
          class: "lead text-default navbar-brand" do
            HTML.raw("<i class='fa fa-cogs text-primary'></i>")
          end
    end
  end

  def path_tree(conn) do
    conn.path_info
    |> Enum.scan([], fn (x, a) -> a ++ [x] end)
    |> Enum.map(fn path -> Enum.join(path, "/") end)
  end

  def path_link(path) do
    if path_exists?(path) do
      link(path_leaf(path), to: "/#{path}")
    else
      path_leaf(path)
    end
  end

  defp path_exists?(path) do
    BayberryWeb.Router.__routes__
    |> Enum.map(fn route -> route.path end)
    |> Enum.member?("/#{path}")
  end

  defp path_leaf(path) do
    [leaf] = Regex.run(~r/[\w\d]+$/, path)
    Regex.replace(~r/[\d]+/, leaf, "id")
  end
end
