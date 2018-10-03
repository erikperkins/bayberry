defmodule PhoenixApp.Nlp do
  alias PhoenixAppWeb.Endpoint

  @api Application.get_env(:phoenix_app, Endpoint)[:nlp]

  def search(term) do
    case HTTPoison.get("#{@api}/#{term}") do
      {:ok, %HTTPoison.Response{body: body}} -> Poison.decode!(body)
      _ -> %{slug: "?", datum: [""]}
    end
  end
end
