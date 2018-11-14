defmodule BayberryWeb.MainController do
  use BayberryWeb, :controller
  import Application, only: [get_env: 2]
  alias Bayberry.WordCloud

  @classifier get_env(:bayberry, Bayberry.Service)[:nlp]
  @redis get_env(:bayberry, Bayberry.Service)[:redis]

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

  def sketch(conn, _params) do
    svg_json =
      Application.app_dir(:bayberry, "/priv/data/architecture.json")
      |> File.read!()
      |> Poison.decode!()

    json(conn, svg_json)
  end

  def topics(conn, _params) do
    json(conn, @classifier.topics())
  end

  def twitter(conn, _params) do
    render(conn, "twitter.html")
  end

  def word_cloud(conn, _params) do
    json(conn, WordCloud.word_count())
  end

  def world_map(conn, _params) do
    geojson =
      Application.app_dir(:bayberry, "/priv/data/countries.geo.json")
      |> File.read!()
      |> Poison.decode!()

    json(conn, geojson)
  end

  def blank(conn, _params) do
    render(conn, "blank.html")
  end
end
