Mix.Tasks.Phx.Phantom.run([])

Application.ensure_all_started(:hound)

ExUnit.start(exclude: [:phantomjs])

Ecto.Adapters.SQL.Sandbox.mode(Bayberry.Repo, :manual)

defmodule Ecto.Reaper do
  def unload(struct, field, cardinality \\ :one) do
    not_loaded = %Ecto.Association.NotLoaded{
      __field__: field,
      __owner__: struct.__struct__,
      __cardinality__: cardinality
    }

    %{struct | field => not_loaded}
  end
end
