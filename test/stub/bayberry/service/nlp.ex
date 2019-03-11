defmodule Stub.Bayberry.Service.NLP do
  def search(term) do
    %{slug: term, datum: ["terms"]}
  end

  def topics() do
    "priv/data/topics.json"
    |> File.read!()
    |> Jason.decode!()
  end
end
