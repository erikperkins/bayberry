defmodule Bayberry.Geolocation.Point do
  use Ecto.Schema

  schema "points" do
    field :ip_from, :integer
    field :ip_to, :integer
    field :country_code, :string
    field :country_name, :string
    field :region_name, :string
    field :city_name, :string
    field :latitude, :decimal
    field :longitude, :decimal
    field :zip_code, :string
    field :time_zone, :string
  end
end
