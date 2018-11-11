defmodule Bayberry.Administration do
  alias Bayberry.Administration.{Analytics, Visit, Visitor}
  alias Bayberry.Repo
  alias BayberryWeb.Endpoint
  import Ecto.Query, only: [from: 2]

  def record_visit(conn) do
    case find_visitor(conn) do
      visitor = %Visitor{latitude: latitude} ->
        if latitude do
          create_visit(visitor, conn)
        else
          update_visitor(visitor, conn)
        end

      nil -> create_visitor(conn)
    end

    conn
  end

  def stream_visits(_ref) do
    query =
      from r in Visitor,
        join: t in Visit,
        on: r.id == t.visitor_id,
        distinct: true,
        select: %{
          id: r.id,
          latitude: type(r.latitude, :float),
          longitude: type(r.longitude, :float),
          bot: fragment("? !~ '(Chrome|Safari|Firefox)\/[0-9]+'", t.user_agent)
        },
        limit: 50,
        order_by: [desc: r.id]

    stream = Repo.stream(query)

    Repo.transaction(fn ->
      for point <- stream do
        Endpoint.broadcast!("geolocation:visitor", "visit", point)
      end
    end)
  end

  defp build_visit(conn) do
    %Visit{path: conn.request_path, user_agent: Analytics.user_agent(conn)}
  end

  defp build_visitor(conn) do
    %Visitor{ip_address: Analytics.ip_address(conn)}
  end

  defp find_visitor(%Plug.Conn{} = conn) do
    conn
    |> Analytics.ip_address()
    |> (&Repo.get_by(Visitor, ip_address: &1)).()
  end

  defp find_visitor(%Visit{} = visit) do
    Repo.get!(Visitor, visit.visitor_id)
  end

  defp locate_visitor(%Visitor{} = visitor, conn) do
    location = Analytics.geolocate(conn)

    visitor
    |> Visitor.changeset(location)
    |> Repo.update()
  end

  defp create_visitor(conn) do
    conn
    |> build_visitor
    |> Repo.insert!()
    |> Ecto.build_assoc(:visits, build_visit(conn))
    |> Repo.insert!()
    |> find_visitor
    |> (&spawn(fn -> locate_visitor(&1, conn) end)).()
  end

  defp create_visit(%Visitor{} = visitor, conn) do
    visitor
    |> Ecto.build_assoc(:visits, build_visit(conn))
    |> Repo.insert!()
  end

  defp update_visitor(%Visitor{} = visitor, conn) do
    visitor
    |> Ecto.build_assoc(:visits, build_visit(conn))
    |> Repo.insert!()

    spawn(fn -> locate_visitor(visitor, conn) end)
  end
end
