defmodule Bayberry.Administration do
  alias Bayberry.Administration.{Analytics, Visit, Visitor}
  alias Bayberry.Repo
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

  def find_visitor(conn) do
    conn
    |> Analytics.forwarded_for
    |> Analytics.ip_string
    |> (&Repo.get_by(Visitor, ip_address: &1)).()
  end

  defp build_visitor(conn) do
    %{latitude: latitude, longitude: longitude} = Analytics.geolocate(conn)

    %Visitor{
      latitude: latitude,
      longitude: longitude,
      ip_address: conn |> Analytics.forwarded_for |> Analytics.ip_string
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
      user_agent: Analytics.user_agent(conn)
    }
  end
end
