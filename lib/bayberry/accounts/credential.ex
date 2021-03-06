defmodule Bayberry.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bayberry.Accounts.{Crypto, User}

  schema "credentials" do
    field :email, :string
    field :password, :string
    field :password_confirmation, :string, virtual: true
    field :salt, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :password, :password_confirmation, :salt])
    |> add_salt
    |> hash_password
    |> validate_required([:email, :password])
    |> validate_confirmation(:password, message: "passwords do not match")
    |> unique_constraint(:email)
  end

  defp add_salt(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      _ -> change(changeset, salt: Crypto.salt())
    end
  end

  defp hash_password(changeset) do
    with password when not is_nil(password) <- get_change(changeset, :password),
         salt when not is_nil(password) <- get_change(changeset, :salt) do
      change(changeset, password: Crypto.hash(salt, password))
    else
      _ -> changeset
    end
  end
end
