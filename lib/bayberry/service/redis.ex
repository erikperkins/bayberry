defmodule Bayberry.Service.Redis do
  import Application, only: [get_env: 2]
  alias Supervisor.Spec

  def command(conn, command) do
    Redix.command(conn, command)
  end

  def json(file) do
    case command(:redix, ["get", file]) do
      {:ok, value} when not is_nil(value) ->
        IO.puts("got #{file} from redis")
        Jason.decode!(value)

      _ ->
        value =
          Application.app_dir(:bayberry, "/priv/data/#{file}.json")
          |> File.read!()

        command(:redix, ["set", file, value])
        Jason.decode!(value)
    end
  end

  def worker() do
    host = get_env(:bayberry, :redis)[:host]
    database = get_env(:bayberry, :redis)[:database]
    password = get_env(:bayberry, :redis)[:password]
    connection = [
      host: host,
      port: 6379,
      database: database,
      password: password,
      name: :redix
    ]

    Spec.worker(Redix, [connection])
  end
end
