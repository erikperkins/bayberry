defmodule BayberryWeb.CMS.PageView do
  use BayberryWeb, :view

  alias Bayberry.CMS

  def author_name(%CMS.Page{author: author}) do
    author.user.name
  end
end
