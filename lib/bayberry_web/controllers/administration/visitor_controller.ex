defmodule BayberryWeb.Administration.VisitorController do
  use BayberryWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def world_map(conn, _params) do
    world_map =
      Application.app_dir(:bayberry, "/priv/data/world-map.json")
      |> File.read!()
      |> Poison.decode!()

    json(conn, world_map)
  end

  def locations(conn, _params) do
    json(conn, Bayberry.Administration.find_visits())
  end
end
