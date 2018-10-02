defmodule PhoenixApp.Nlp do
  def search(term) do
    case HTTPoison.get("http://main.datapun.net:1025/lda/#{term}") do
      {:ok, %HTTPoison.Response{body: body}} -> Poison.decode!(body)
      _ -> %{slug: "?", datum: [""]}
    end
  end
end
