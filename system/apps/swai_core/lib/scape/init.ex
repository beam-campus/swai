defmodule Scape.Init do
  @moduledoc """
  Scape.InitParams is a struct that holds the parameters for initializing a scape.
  """
  use Ecto.Schema

  import Ecto.Changeset
  require MnemonicSlugs

  alias Scape.Init, as: ScapeInit
  alias Schema.Scape, as: Scape
  alias Schema.Vector, as: Vector

  @all_fields [
    :id,
    :name,
    :license_id,
    :swarm_id,
    :swarm_name,
    :swarm_size,
    :swarm_time_min,
    :user_id,
    :biotope_id,
    :algorithm_id,
    :algorithm_acronym,
    :dimensions
  ]

  @flat_fields [
    :id,
    :name,
    :license_id,
    :swarm_id,
    :swarm_name,
    :swarm_size,
    :swarm_time_min,
    :user_id,
    :biotope_id,
    :algorithm_id,
    :algorithm_acronym
  ]

  @required_fields [
    :id,
    :license_id,
    :swarm_id,
    :swarm_name,
    :swarm_size,
    :swarm_time_min,
    :user_id,
    :biotope_id,
    :algorithm_id,
    :algorithm_acronym,
    :dimensions
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:id, :binary_id, default: UUID.uuid4())
    field(:name, :string, default: ("scape_" <> MnemonicSlugs.generate_slug(2))  |> String.replace("-", "_"))
    field(:license_id, :binary_id)
    field(:swarm_id, :binary)
    field(:swarm_name, :string)
    field(:swarm_size, :integer, default: 100)
    field(:swarm_time_min, :integer, default: 60)
    field(:user_id, :binary_id)
    field(:biotope_id, :binary_id)
    field(:algorithm_id, :binary_id)
    field(:algorithm_acronym, :string)
    embeds_one(:dimensions, Vector)
  end


  def changeset(%ScapeInit{} = seed, %{} = args) when is_struct(args),
    do: changeset(seed, Map.from_struct(args))

  def changeset(%ScapeInit{} = seed, args)
      when is_map(args) do
    seed
    |> cast(args, @flat_fields)
    |> cast_embed(:dimensions, with: &Vector.changeset/2)
    |> validate_required(@required_fields)
  end

  def from_map(%ScapeInit{} = seed, map) when is_struct(map),
    do: from_map(seed, Map.from_struct(map))

  def from_map(%ScapeInit{} = seed, map) when is_map(map) do
    case(changeset(seed, map)) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
