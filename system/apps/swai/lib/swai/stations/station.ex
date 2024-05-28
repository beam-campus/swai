defmodule Swai.Stations.Station do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "stations" do
    field :name, :string
    field :add, :string
    field :description, :string
    field :user_id, :string
    field :location_id, :string
    field :gateway, :string
    field :nature, :string
    timestamps()
  end

  @doc false
  def changeset(station, attrs) do
    station
    |> cast(attrs, [:add, :name, :description, :user_id, :location_id, :gateway, :nature])
    |> validate_required([:add, :name, :description, :user_id, :location_id, :gateway, :nature])
  end
end
