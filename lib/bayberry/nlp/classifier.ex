defmodule Bayberry.NLP.Classifier do
  alias BayberryWeb.Endpoint

  @api Application.get_env(:bayberry, Endpoint)[:nlp]

  def search(term) do
    case HTTPoison.get("#{@api}/#{term}") do
      {:ok, %HTTPoison.Response{body: body}} -> Poison.decode!(body)
      _ -> %{slug: "?", datum: [""]}
    end
  end
end
