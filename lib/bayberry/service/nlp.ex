defmodule Bayberry.Service.NLP do
  alias HTTPoison.Response

  def search(term) do
    case HTTPoison.get("http://main.datapun.net:1025/lda/#{term}") do
      {:ok, %Response{body: body}} -> Poison.decode!(body)
      _ -> %{slug: "?", datum: [""]}
    end
  end

  def topics() do
    case HTTPoison.get("http://main.datapun.net:1025/lda/") do
      {:ok, %Response{body: body}} ->
        Poison.decode!(body)

      _ ->
        "priv/data/topics.json"
        |> File.read!
        |> Poison.decode!
    end
  end
end
