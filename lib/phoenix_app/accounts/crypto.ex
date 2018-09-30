defmodule PhoenixApp.Accounts.Crypto do
  @moduledoc """
  Password salt and hash.
  """

  def salt() do
    :crypto.strong_rand_bytes(32)
    |> Base.encode16()
    |> String.downcase()
  end

  def hash(salt, password) do
    :crypto.hash(:sha256, salt <> password)
    |> Base.encode16()
    |> String.downcase()
  end
end
