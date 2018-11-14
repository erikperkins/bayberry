defmodule Stub.Bayberry.Service.GenServer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :redix)
  end

  def init(%{}) do
    {:ok, %{}}
  end
end
