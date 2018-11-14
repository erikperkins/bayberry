defmodule Stub.Bayberry.Service.Redis do
  alias Supervisor.Spec

  def command(_conn, _command) do
    {:ok, nil}
  end

  def json(file) do
    Application.app_dir(:bayberry, "/priv/data/#{file}.json")
    |> File.read!()
    |> Poison.decode!()
  end

  def worker() do
    Spec.worker(Stub.Bayberry.Service.GenServer, [], restart: :permanent)
  end
end
