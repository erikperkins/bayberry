defmodule Bayberry.Visitor do
  use Ecto.Schema
  import Ecto.Changeset


  schema "visitors" do
    field :ip_address, :string
    field :latitude, :decimal
    field :longitude, :decimal
    field :user_agent, :string
    field :path, :string

    timestamps()
  end

  @doc false
  def changeset(visitor, attrs) do
    visitor
    |> cast(attrs, [:ip_address, :latitude, :longitude, :user_agent, :path])
    |> validate_required([:ip_address, :latitude, :longitude, :user_agent, :path])
  end
end
