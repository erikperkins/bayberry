defmodule Bayberry.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string
      add :body, :text
      add :views, :integer, default: 0

      timestamps()
    end

  end
end
