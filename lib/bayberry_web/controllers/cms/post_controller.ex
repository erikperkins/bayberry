defmodule BayberryWeb.PostController do
  use BayberryWeb, :controller
  use Timex

  alias Bayberry.CMS
  # alias Bayberry.CMS.Page

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
