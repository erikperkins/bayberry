defmodule Bayberry.Repo.Migrations.AddPasswordHashToCredentials do
  use Ecto.Migration

  alias Bayberry.Accounts.Crypto

  def change do
    alter table(:credentials) do
      add :password, :string, size: 64, default: Crypto.hash("salt", "password"), null: false
      add :salt, :string, null: false
    end

    create constraint("credentials", "char_length_64", check: "char_length(password) = 64")
  end
end
