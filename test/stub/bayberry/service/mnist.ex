defmodule Stub.Bayberry.Service.MNIST do
  def digit(_id) do
    Process.sleep(250)

    digits()
    |> Enum.random()
  end

  def digits() do
    "priv/data/digits.json"
    |> File.read!()
    |> Poison.decode!()
  end

  def classify(_image) do
    %{new: true, classification: 0}
  end
end
