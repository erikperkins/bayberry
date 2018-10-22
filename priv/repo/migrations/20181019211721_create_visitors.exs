defmodule Bayberry.Repo.Migrations.CreateVisitors do
  use Ecto.Migration

  def change do
    create table(:visitors) do
      add :ip_address, :string
      add :latitude, :decimal
      add :longitude, :decimal
    end

    create unique_index(:visitors, [:ip_address])
  end
end
