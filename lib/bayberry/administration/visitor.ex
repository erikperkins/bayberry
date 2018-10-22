defmodule Bayberry.Visitor do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bayberry.Visit


  schema "visitors" do
    field :ip_address, :string
    field :latitude, :decimal
    field :longitude, :decimal
    has_many :visits, Visit
  end

  @doc false
  def changeset(visitor, attrs) do
    visitor
    |> cast(attrs, [:ip_address, :latitude, :longitude])
    |> validate_required([:ip_address, :latitude, :longitude])
  end
end
