defmodule PhoenixApp.TwitterController do
  use PhoenixApp.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

end
