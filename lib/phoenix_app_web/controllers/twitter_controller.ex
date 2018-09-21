defmodule PhoenixAppWeb.TwitterController do
  use PhoenixAppWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

end
