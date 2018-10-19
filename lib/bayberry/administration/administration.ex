defmodule Bayberry.Administration do
  alias Bayberry.{Geolocation, Location, Repo, Visitor}
  import Ecto.Query, only: [from: 2]

  def geolocate(conn) do
    conn.remote_ip
    |> ip_integer
    |> find_ip
    |> Geolocation.one
  end

  def record_visit(conn) do
    attrs = conn
    |> geolocate
    |> Map.put(:path, conn.request_path)
    |> Map.put(:ip_address, conn.remote_ip |> ip_string)
    |> Map.put(:user_agent, user_agent(conn))

    %Visitor{}
    |> Visitor.changeset(attrs)
    |> Repo.insert!

    conn
  end

  defp ip_integer(ip) do
    case ip do
      {192, 168, _, _} -> 0
      {172, a, _, _} when a > 15 and a < 32 -> 0
      {127, _, _, _} -> 0
      {10, _, _, _} -> 0
      {a, b, c, d} ->
        :math.pow(256, 3) * a + :math.pow(256, 2) * b + 256 * c + d
        |> trunc
    end
  end

  defp ip_string({a, b, c, d}) do
    "#{a}.#{b}.#{c}.#{d}"
  end

  defp user_agent(conn) do
    [user_agent] = Plug.Conn.get_req_header(conn, "user-agent")
    user_agent
  end

  defp find_ip(ip) do
    fields = [:latitude, :longitude]
    from l in Location,
      where: l.ip_from <= ^ip and ^ip < l.ip_to,
      select: map(l, ^fields)
  end
end
