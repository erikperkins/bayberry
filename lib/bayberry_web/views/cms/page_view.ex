defmodule BayberryWeb.Blog.PageView do
  use BayberryWeb, :view

  alias Bayberry.Blog

  def author_name(%Blog.Page{author: author}) do
    author.user.name
  end
end
