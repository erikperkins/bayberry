defmodule Bayberry.MNIST.Supervisor do
  use DynamicSupervisor

  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_stream() do
    DynamicSupervisor.start_child(__MODULE__, {Bayberry.MNIST.Stream, %{}})
  end

  def stop_stream() do
    stream = GenServer.whereis(Bayberry.MNIST.Stream)
    DynamicSupervisor.terminate_child(__MODULE__, stream)
  end
end
