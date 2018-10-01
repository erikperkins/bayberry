defmodule PhoenixAppWeb.MainController do
  use PhoenixAppWeb, :controller
  alias PhoenixApp.WordCloud

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def architecture(conn, _params) do
    render(conn, "architecture.html")
  end

  def twitter(conn, _params) do
    render(conn, "twitter.html")
  end

  def word_cloud(conn, _params) do
    json(conn, WordCloud.word_count)
  end
end
