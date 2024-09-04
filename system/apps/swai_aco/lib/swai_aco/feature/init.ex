defmodule Feature.Init do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schema.Vector, as: Vector
  alias Feature.Init, as: FeatureInit

  require Logger
  require Jason.Encoder

  @all_fields [
    :type,
    :intensity,
    :location,
    :radius,
    :is_collectable?
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:type, :integer)
    field(:intensity, :float)
    embeds_one(:location, Vector, on_replace: :delete)
    field(:radius, :integer)
    field(:is_collectable?, :boolean)
  end

  def changeset(seed, struct)
      when is_struct(struct),
      do: changeset(seed, struct |> Map.from_struct())

  def changeset(init, attrs)
      when is_map(attrs),
      do:
        init
        |> cast(attrs, @all_fields)
        |> validate_required(@all_fields)

  def from_map(seed, attrs) do
    case changeset(seed, attrs) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
