defmodule BayberryWeb.Plugs.Geolocation do
  def init(_params) do
  end

  def call(conn, _params) do
    spawn(fn -> Bayberry.Administration.record_visit(conn) end)
    conn
  end
end
