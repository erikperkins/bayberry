defmodule BayberryWeb.ResourceController do
  use BayberryWeb, :controller
  import Application, only: [get_env: 2]
  alias Bayberry.WordCloud

  @classifier get_env(:bayberry, Bayberry.Service)[:nlp]
  @redis get_env(:bayberry, Bayberry.Service)[:redis]

  def architecture(conn, _params) do
    @redis.json("architecture")
    |> (&json(conn, &1)).()
  end

  def topics(conn, _params) do
    json(conn, @classifier.topics())
  end

  def word_cloud(conn, _params) do
    json(conn, WordCloud.word_count())
  end

  def world_map(conn, _params) do
    @redis.json("countries.geo")
    |> (&json(conn, &1)).()
  end
end
