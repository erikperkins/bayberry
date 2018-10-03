defmodule PhoenixAppWeb.CMS.PageView do
  use PhoenixAppWeb, :view

  alias PhoenixApp.CMS

  def author_name(%CMS.Page{author: author}) do
    author.user.name
  end
end
