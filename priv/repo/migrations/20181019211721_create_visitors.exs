defmodule Bayberry.Repo.Migrations.CreateVisitors do
  use Ecto.Migration

  def change do
    create table(:visitors) do
      add :ip_address, :string
      add :latitude, :decimal
      add :longitude, :decimal
      add :user_agent, :string
      add :path, :string

      timestamps()
    end

  end
end
