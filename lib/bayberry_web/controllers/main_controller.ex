defmodule BayberryWeb.MainController do
  use BayberryWeb, :controller

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

  def blank(conn, _params) do
    render(conn, "blank.html")
  end
end
