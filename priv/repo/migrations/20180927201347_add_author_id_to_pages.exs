defmodule Bayberry.Repo.Migrations.AddAuthorIdToArticles do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      add :author_id, references(:authors, on_delete: :delete_all), null: false
    end

    create index(:articles, [:author_id])
  end
end
