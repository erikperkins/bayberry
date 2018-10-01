defmodule PhoenixApp.Nlp do
  def search(term) do
    case HTTPoison.get!("http://main.datapun.net:1025/lda/#{term}") do
      %{body: body} -> Poison.decode!(body)
      _ -> %{slug: "?", datum: [""]}
    end
  end
end
