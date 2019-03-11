defmodule Bayberry.Service.NLP do
  import Application, only: [get_env: 2]
  alias HTTPoison.Response

  @redis get_env(:bayberry, Bayberry.Service)[:redis]

  def search(term) do
    case HTTPoison.get("#{get_env(:bayberry, :data_punnet)[:lda]}/#{term}") do
      {:ok, %Response{body: body}} -> Jason.decode!(body)
      _ -> %{slug: "?", datum: [""]}
    end
  end

  def topics() do
    case HTTPoison.get(get_env(:bayberry, :data_punnet)[:lda]) do
      {:ok, %Response{body: body}} -> Jason.decode!(body)
      _ -> @redis.json("topics")
    end
  end
end
