defmodule Stub.Bayberry.Service.Redis do
  alias Supervisor.Spec

  def command(_conn, command) do
    case command do
      ["get", "twitter:track"] ->
        hashtags = "#randomtweet,#wikipedia,#goodrant,#powerrant,#midnightbling"
        {:ok, hashtags}

      _ -> {:ok, nil}
    end
  end

  def json(file) do
    Application.app_dir(:bayberry, "/priv/data/#{file}.json")
    |> File.read!()
    |> Jason.decode!()
  end

  def worker() do
    Spec.worker(Stub.Bayberry.Service.GenServer, [], restart: :permanent)
  end
end
