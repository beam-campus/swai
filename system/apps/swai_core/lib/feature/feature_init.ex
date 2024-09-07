defmodule Feature.Init do
  use Ecto.Schema

  @moduledoc """
  Feature.InitParams is a struct that holds the parameters for initializing a feature.
  """

  import Ecto.Changeset

  require Logger
  require Jason.Encoder

  @all_fields [
    :id,
    :name,
    :description,
    :type,
    :tags,
    :image_url,
    :orientation,
    :scale,
    :color,
    :opacity,
    :size,
    :shape,
    :features
  ]

  @required_fields [
    :type,
    :color
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:id, :binary_id, default: UUID.uuid4())
    field(:name, :string)
    field(:description, :string, default: "")
    field(:type, :string)
    field(:tags, :string)
    field(:image_url, :string, default: "")
    field(:orientation, :float)
    field(:scale, :float)
    field(:color, :string)
    field(:opacity, :float)
    field(:size, :float)
    field(:shape, :string)
    field(:features, :map, default: %{})
  end

  def changeset(seed, struct)
      when is_struct(struct),
      do: changeset(seed, Map.from_struct(struct))

  def changeset(seed, args)
      when is_map(args) do
    seed
    |> cast(args, @all_fields)
    |> validate_required(@required_fields)
  end

  def from_map(seed, struct)
      when is_struct(struct),
      do: from_map(seed, Map.from_struct(struct))

  def from_map(feature, args)
      when is_map(args) do
    case changeset(feature, args) do
      {:ok, feature} -> feature
      {:error, changeset} -> changeset
    end
  end
end
