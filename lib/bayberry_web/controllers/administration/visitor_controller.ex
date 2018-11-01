defmodule BayberryWeb.Administration.VisitorController do
  use BayberryWeb, :controller

  def world_map(conn, _params) do
    world_map =
      Application.app_dir(:bayberry, "/priv/data/world-map.json")
      |> File.read!()
      |> Poison.decode!()

    json(conn, world_map)
  end
end
