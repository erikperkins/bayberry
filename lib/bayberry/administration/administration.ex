defmodule Bayberry.Administration do
  alias Bayberry.{Geolocation, Location, Repo, Visit, Visitor}
  import Ecto.Query, only: [from: 2]

  def record_visit(conn) do
    case find_visitor(conn) do
      nil ->
        build_visitor(conn)
        |> Repo.insert!
        |> Ecto.build_assoc(:visits, build_visit(conn))
        |> Repo.insert!
      visitor = %Visitor{} ->
        visitor
        |> Ecto.build_assoc(:visits, build_visit(conn))
        |> Repo.insert!
    end
  end

  def geolocate(conn) do
    conn
    |> forwarded_for
    |> ip_integer
    |> query_location
    |> Geolocation.one
  end

  def find_visitor(conn) do
    conn
    |> forwarded_for
    |> ip_string
    |> (&Repo.get_by(Visitor, ip_address: &1)).()
  end

  defp build_visitor(conn) do
    %{latitude: latitude, longitude: longitude} = geolocate(conn)

    %Visitor{
      latitude: latitude,
      longitude: longitude,
      ip_address: conn |> forwarded_for |> ip_string
    }
  end

  def find_visits do
    query = from v in Visitor,
      select: %{
        latitude: type(v.latitude, :float),
        longitude: type(v.longitude, :float)
      }

    Repo.all(query)
  end

  defp build_visit(conn) do
    %Visit{
      path: conn.request_path,
      user_agent: user_agent(conn)
    }
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

  defp forwarded_for(conn) do
    Plug.Conn.get_req_header(conn, "x-forwarded-for")
    |> Enum.at(0)
    |> String.split(".")
    |> Enum.map(fn a -> Integer.parse a end)
    |> Enum.map(fn {a, _} -> a end)
    |> List.to_tuple
  end

  defp user_agent(conn) do
    Plug.Conn.get_req_header(conn, "user-agent")
    |> Enum.at(0)
  end

  defp query_location(ip) do
    from l in Location,
      where: l.ip_from <= ^ip and ^ip < l.ip_to,
      select: %{latitude: l.latitude, longitude: l.longitude}
  end
end
