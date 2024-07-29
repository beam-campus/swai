defmodule Schema.Biotope do
  @moduledoc """
  The schema for the biotopes table.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @all_fields [
    :id,
    :name,
    :description,
    :objective,
    :environment,
    :challenges,
    :image_url,
    :theme,
    :tags,
    :difficulty,
    :is_active?,
    :biotope_type,
    :is_realistic?,
    :scape_id
  ]

  @required_fields [
    :name,
    :description,
    :objective,
    :environment,
    :challenges,
    :image_url,
    :theme,
    :tags,
    :difficulty,
    :is_active?,
    :biotope_type,
    :is_realistic?,
    :scape_id
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "biotopes" do
    field(:is_active?, :boolean, default: false)
    field(:name, :string)
    field(:description, :string)
    field(:objective, :string)
    field(:environment, :string)
    field(:challenges, :string)
    field(:image_url, :string)
    field(:theme, :string)
    field(:tags, :string)
    field(:difficulty, :integer)
    field(:biotope_type, :string, default: "Swarm vs Environment")
    field(:is_realistic?, :boolean, default: false)
    field(:scape_id, :string)
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(biotope, attrs) do
    biotope
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
  end
end
