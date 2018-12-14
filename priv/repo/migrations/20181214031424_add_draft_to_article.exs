defmodule Bayberry.Repo.Migrations.AddDraftToArticle do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      add :draft, :boolean, default: true
    end
  end
end
