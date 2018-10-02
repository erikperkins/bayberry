defmodule PhoenixApp.Mnist do
  def digit(id) do
    case HTTPoison.get("http://mnist.datapun.net/mnist/#{id}.json") do
      {:ok, %HTTPoison.Response{body: body}} -> Poison.decode!(body)
      {:error, %HTTPoison.Error{reason: _}} -> nil
    end
  end

  def classify(image) do
    url = "http://mnist.datapun.net/mnist/new/classification.json"
    json = Poison.encode!(image)
    header = [{"Content-Type", "application/json"}]

    case HTTPoison.post(url, json, header) do
      {:ok, %HTTPoison.Response{body: body}} -> Poison.decode!(body)
      {:error, %HTTPoison.Error{reason: _}} -> nil
    end
  end
end
