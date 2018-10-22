defmodule Bayberry.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits) do
      add :path, :string
      add :user_agent, :string
      add :visitor_id, references(:visitors, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
