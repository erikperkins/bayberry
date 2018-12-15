defmodule Bayberry.Repo.Migrations.AddSummaryToArticle do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      add :summary, :text
    end
  end
end
