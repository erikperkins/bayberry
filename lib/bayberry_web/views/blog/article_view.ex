defmodule BayberryWeb.Blog.ArticleView do
  use BayberryWeb, :view

  alias Bayberry.Blog

  def author_name(%Blog.Article{author: author}) do
    author.user.name
  end
end
