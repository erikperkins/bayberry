defmodule Stub.Bayberry.Service.Redis do
  alias Supervisor.Spec

  def worker() do
    Spec.worker(Stub.Bayberry.Service.Redix, [], restart: :permanent)
  end
end

defmodule Stub.Bayberry.Service.Redix do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :redix)
  end

  def init(%{}) do
    {:ok, %{}}
  end
end
