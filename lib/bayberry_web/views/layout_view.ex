defmodule BayberryWeb.LayoutView do
  use BayberryWeb, :view

  alias Phoenix.HTML

  def session_icon(conn) do
    case Plug.Conn.get_session(conn, :user_id) do
      nil -> HTML.raw("<i class='fa fa-sign-in text-success'></i>")
      _ -> HTML.raw("<i class='fa fa-sign-out text-warning'></i>")
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
