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
