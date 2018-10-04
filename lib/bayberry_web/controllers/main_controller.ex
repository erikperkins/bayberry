defmodule BayberryWeb.MainController do
  use BayberryWeb, :controller
  alias Bayberry.WordCloud

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def architecture(conn, _params) do
    render(conn, "architecture.html")
  end

  def mnist(conn, _params) do
    render(conn, "mnist.html")
  end

  def nlp(conn, _params) do
    render(conn, "nlp.html")
  end

  def twitter(conn, _params) do
    render(conn, "twitter.html")
  end

  def word_cloud(conn, _params) do
    json(conn, WordCloud.word_count)
  end
end
