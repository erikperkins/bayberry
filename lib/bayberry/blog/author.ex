defmodule Bayberry.Blog.Author do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bayberry.Blog.Article

  schema "authors" do
    field :bio, :string
    field :genre, :string
    field :role, :string
    has_many :articles, Article
    belongs_to :user, Bayberry.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:bio, :role, :genre])
    |> validate_required([:bio, :role, :genre])
    |> unique_constraint(:user_id)
  end
end
