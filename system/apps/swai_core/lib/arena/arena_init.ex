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
  alias Arena.ArenaMap, as: ArenaMap
  alias Swai.Defaults, as: Defaults

  @hexa_size Defaults.arena_hexa_size()
  @map_width Defaults.arena_width()
  @map_height Defaults.arena_height()

  @maze_density Defaults.arena_maze_density()

  @all_fields [
    :arena_id,
    :edge_id,
    :scape_id,
    :scape_name,
    :hives_cap,
    :biotope_id,
    :dimensions,
    :arena_map
  ]

  @required_fields [
    :arena_id,
    :edge_id,
    :scape_id,
    :biotope_id,
    :hives_cap
  ]

  @flat_fields [
    :arena_id,
    :edge_id,
    :scape_id,
    :scape_name,
    :biotope_id,
    :hives_cap
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:arena_id, :string, default: "arena-#{UUID.uuid4()}")
    field(:edge_id, :string)
    field(:scape_id, :string)
    field(:biotope_id, :binary_id)
    field(:hives_cap, :integer)
    field(:scape_name, :string)
    embeds_one(:dimensions, Vector, on_replace: :delete)
    embeds_one(:arena_map, ArenaMap, on_replace: :delete)
  end

  def changeset(seed, struct)
      when is_struct(struct),
      do: changeset(seed, Map.from_struct(struct))

  def changeset(arena, args)
      when is_map(args) do
    arena
    |> cast(args, @flat_fields)
    |> cast_embed(:dimensions, with: &Vector.changeset/2)
    |> cast_embed(:arena_map, with: &ArenaMap.changeset/2)
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

  def new(%ScapeInit{hives_cap: hives_cap} = scape_init) do
    seed =
      %ArenaInit{
        arena_id: "arena-#{UUID.uuid4()}",
        arena_map:
          ArenaMap.generate(
            @map_width,
            @map_height,
            @hexa_size,
            @maze_density,
            hives_cap
          ),
        dimensions: ArenaMap.default_dimensions()
      }

    Logger.debug("ArenaInit.new seed: 

      #{inspect(seed)}

      ")

    seed
    |> from_map(scape_init)
  end
end
