defmodule BayberryWeb.MainView do
  use BayberryWeb, :view
  import Application, only: [get_env: 2]

  @redis get_env(:bayberry, Bayberry.Service)[:redis]

  def twitter_track() do
    {:ok, track} = @redis.command(:redix, ["get", "twitter:track"])
    track
    |> String.split(",")
    |> Enum.join(", ")
  end
end
