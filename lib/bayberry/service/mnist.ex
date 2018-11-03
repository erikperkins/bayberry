defmodule Bayberry.Service.MNIST do
  alias HTTPoison.{Error, Response}

  def digit(id) do
    case HTTPoison.get("http://mnist.datapun.net/mnist/#{id}.json") do
      {:ok, %Response{body: body}} -> Poison.decode!(body)
      {:error, %Error{reason: _}} -> nil
    end
  end

  def digits() do
    "priv/data/digits.json"
    |> File.read!()
    |> Poison.decode!()
  end

  def classify(image) do
    url = "http://mnist.datapun.net/mnist/new/classification.json"
    json = Poison.encode!(image)
    header = [{"Content-Type", "application/json"}]

    case HTTPoison.post(url, json, header) do
      {:ok, %Response{body: body}} -> Poison.decode!(body)
      {:error, %Error{reason: _}} -> nil
    end
  end
end
