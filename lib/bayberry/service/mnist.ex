defmodule Bayberry.Service.MNIST do
  import Application, only: [get_env: 2]
  require Logger
  alias HTTPoison.{Error, Response}

  @redis get_env(:bayberry, Bayberry.Service)[:redis]

  def digit(id) do
    case HTTPoison.get("#{get_env(:bayberry, :data_punnet)[:mnist]}/#{id}") do
      {:ok, %Response{body: body}} ->
        Jason.decode!(body)

      {:error, %Error{reason: :closed}} ->
        Logger.warn("Retrying image #{id}")
        digit(id)

      {:error, %Error{reason: reason}} ->
        Logger.warn("Failed to get image #{id}: #{reason}")
        :error
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
      {:error, %Error{reason: _}} -> %{}
    end
  end

  def threads() do
    get_env(:bayberry, :mnist)[:threads]
    |> String.to_integer
  end
end
