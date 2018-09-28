defmodule PhoenixAppWeb.MainController do
  use PhoenixAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def architecture(conn, _params) do
    render(conn, "architecture.html")
  end

  def twitter(conn, _params) do
    render(conn, "twitter.html")
  end
end
