defmodule BayberryWeb.PostController do
  use BayberryWeb, :controller
  use Timex

  alias Bayberry.Blog

  def index(conn, _params) do
    posts = Blog.list_pages()
    render(conn, "index.html", posts: posts)
  end

  def show(conn, %{"id" => id}) do
    post = id
      |> Blog.get_page!()
      |> Blog.increment_page_views()

    render(conn, "show.html", post: post)
  end
end
