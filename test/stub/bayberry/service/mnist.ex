defmodule Stub.Bayberry.Service.MNIST do
  def digit(_id) do
    "priv/data/digit.json"
    |> File.read!()
    |> Poison.decode!()
  end

  def classify(_image) do
    %{new: true, classification: 0}
  end
end
