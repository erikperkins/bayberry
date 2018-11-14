defmodule Bayberry.Service.Redis do
  alias Supervisor.Spec

  def command(conn, command) do
    Redix.command(conn, command)
  end

  def json(file) do
    case command(:redix, ["get", file]) do
      {:ok, value} when not is_nil(value) ->
        IO.puts("got #{file} from redis")
        Poison.decode!(value)

      _ ->
        value =
          Application.app_dir(:bayberry, "/priv/data/#{file}.json")
          |> File.read!()

        command(:redix, ["set", file, value])
        Poison.decode!(value)
    end
  end

  def worker() do
    host = "storage.datapun.net"
    Spec.worker(Redix, [[host: host, port: 6379, database: 3], [name: :redix]])
  end
end
