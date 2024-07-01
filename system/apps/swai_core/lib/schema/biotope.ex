defmodule Schema.Biotope do
  @moduledoc """
  The schema for the biotopes table.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "biotopes" do
    field :name, :string
    field :description, :string
    field :image_url, :string
    field :theme, :string
    field :tags, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(biotope, attrs) do
    biotope
    |> cast(attrs, [:name, :description, :image_url, :theme, :tags])
    |> validate_required([:name, :description, :image_url, :theme, :tags])
  end
end
