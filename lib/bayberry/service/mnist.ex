defmodule Bayberry.Service.MNIST do
  import Application, only: [get_env: 2]
  alias HTTPoison.{Error, Response}

  @redis get_env(:bayberry, Bayberry.Service)[:redis]

  def digit(id) do
    case HTTPoison.get("#{get_env(:bayberry, :data_punnet)[:mnist]}/#{id}") do
      {:ok, %Response{body: body}} -> Jason.decode!(body)
      {:error, %Error{reason: _}} -> nil
    end
  end

  def digits() do
    @redis.json("digits")
  end

  def classify(image) do
    url = get_env(:bayberry, :data_punnet)[:mnist]
    json = Jason.encode!(image)
    header = [{"Content-Type", "application/json"}]

    case HTTPoison.post(url, json, header) do
      {:ok, %Response{body: body}} -> Jason.decode!(body)
      {:error, %Error{reason: _}} -> nil
    end
  end
end
