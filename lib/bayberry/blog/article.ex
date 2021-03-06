defmodule Bayberry.Blog.Article do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bayberry.Blog.Author

  schema "articles" do
    field :body, :string
    field :summary, :string
    field :title, :string
    field :views, :integer
    field :draft, :boolean, default: true
    belongs_to :author, Author

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :summary, :body, :draft])
    |> validate_required([:title, :summary, :body])
  end
end
