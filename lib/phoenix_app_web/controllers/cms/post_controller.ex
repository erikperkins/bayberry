defmodule PhoenixAppWeb.PostController do
  use PhoenixAppWeb, :controller
  use Timex

  alias PhoenixApp.CMS
  # alias PhoenixApp.CMS.Page

  def index(conn, _params) do
    posts = CMS.list_pages()
    render(conn, "index.html", posts: posts)
  end

  def show(conn, %{"id" => id}) do
    post = id
      |> CMS.get_page!()
      |> CMS.increment_page_views()

    render(conn, "show.html", post: post)
  end
end
