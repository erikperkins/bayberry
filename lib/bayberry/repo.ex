defmodule Bayberry.Repo do
  use Ecto.Repo, otp_app: :bayberry, adapter: Ecto.Adapters.Postgres
end
