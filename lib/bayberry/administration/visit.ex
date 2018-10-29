defmodule Bayberry.Administration.Visit do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bayberry.Administration.Visitor

  schema "visits" do
    field :path, :string
    field :user_agent, :string
    belongs_to :visitor, Visitor

    timestamps()
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:path, :user_agent])
    |> validate_required([:path, :user_agent])
  end
end
