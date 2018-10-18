defmodule BayberryWeb.Accounts.AdministrationController do
  use BayberryWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def visitors(conn, _params) do
    render(conn, "visitors.html")
  end

  def world_map(conn, _params) do
    world_map = Application.app_dir(:bayberry, "/priv/data/world-map.json")
    |> File.read!
    |> Poison.decode!
    json(conn, world_map)
  end

  def locations(conn, _params) do
    json(conn, [[-119.7, 34.4], [-118.2, 37.2], [-122.4, 37.7]])
  end
end
