defmodule Arena.Init do
  @moduledoc """
  This module is responsible for managing the arena in the system.
  """

  use Ecto.Schema

  import Ecto.Changeset

  require Logger
  require Jason.Encoder

  alias Arena.Init, as: ArenaInit
  alias Schema.Vector, as: Vector
  alias Scape.Init, as: ScapeInit

  @all_fields [
    :edge_id,
    :scape_id,
    :biotope_id,
    :nbr_of_hives,
    :swarm_size,
    :swarm_time_min,
    :dimensions,
    :field_features
  ]

  @required_fields [
    :edge_id,
    :scape_id,
    :biotope_id
  ]

  @flat_fields [
    :edge_id,
    :scape_id,
    :biotope_id,
    :nbr_of_hives,
    :swarm_size,
    :swarm_time_min
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:edge_id, :binary_id)
    field(:scape_id, :binary_id)
    field(:biotope_id, :binary_id)
    field(:swarm_size, :integer, default: 100)
    field(:swarm_time_min, :integer, default: 60)
    field(:nbr_of_hives, :integer, default: 1)
    embeds_one(:dimensions, Vector, on_replace: :delete)
    embeds_one(:field_features, :map, on_replace: :delete)
  end

  def changeset(seed, struct)
      when is_struct(struct),
      do: changeset(seed, Map.from_struct(struct))

  def changeset(arena, args)
      when is_map(args) do
    arena
    |> cast(args, @flat_fields)
    |> cast_embed(:dimensions, with: &Vector.changeset/2)
    |> validate_required(@required_fields)
  end

  def from_map(seed, map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        Logger.error("Failed to create arena: #{inspect(changeset)}")
        {:error, changeset}
    end
  end

  def from_scape_init(%ScapeInit{dimensions: dimensions} = scape_init) do
    seed = %ArenaInit{
      scape_id: scape_init.id,
      field_features: %{}
    }

    arena_init =
      case ArenaInit.from_map(seed, scape_init) do
        {:ok, arena_init} ->
          arena_init

        {:error, reason} ->
          Logger.error("Failed to get arena_init from scape_init: #{reason}")
          seed
      end
  end
end
