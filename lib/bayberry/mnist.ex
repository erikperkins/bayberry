defmodule Bayberry.Mnist do
  alias BayberryWeb.Endpoint

  @api Application.get_env(:bayberry, Endpoint)[:mnist]

  def digit(id) do
    case HTTPoison.get("#{@api}/#{id}.json") do
      {:ok, %HTTPoison.Response{body: body}} -> Poison.decode!(body)
      {:error, %HTTPoison.Error{reason: _}} -> nil
    end
  end

  def classify(image) do
    url = "#{@api}/new/classification.json"
    json = Poison.encode!(image)
    header = [{"Content-Type", "application/json"}]

    case HTTPoison.post(url, json, header) do
      {:ok, %HTTPoison.Response{body: body}} -> Poison.decode!(body)
      {:error, %HTTPoison.Error{reason: _}} -> nil
    end
  end
end
