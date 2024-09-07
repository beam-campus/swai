defmodule Arena.ArenaMap do
  @moduledoc """
  This module is responsible for managing the arena map in the system.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Arena.ArenaMap, as: ArenaMap
  alias Arena.Hexa, as: Hexa
  alias Schema.Vector, as: Vector
  alias Swai.Defaults, as: Defaults
  alias Scape.Utils, as: ScapeUtils
  alias Feature.Init, as: Feature

  @map_width Defaults.arena_width()
  @map_height Defaults.arena_height()
  @map_hexa_size Defaults.arena_hexa_size()
  @maze_density Defaults.arena_maze_density()

  @all_fields [
    :width,
    :height,
    :hexa_size,
    :maze_density,
    :maze,
    :collectibles,
    :particles,
    :threats,
    :hives
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:width, :integer, default: @map_width)
    field(:height, :integer, default: @map_height)
    field(:hexa_size, :integer, default: @map_hexa_size)
    field(:maze_density, :integer, default: @maze_density)
    field(:maze, {:array, :map}, default: [])
    field(:collectibles, {:array, :map}, default: [])
    field(:particles, {:array, :map}, default: [])
    field(:threats, {:array, :map}, default: [])
    field(:hives, {:array, :map}, default: [])
  end

  def changeset(arena_map, attrs)
      when is_map(attrs) do
    arena_map
    |> cast(attrs, @all_fields)
    |> validate_required(@all_fields)
  end

  def generate(width, height, hexa_size, maze_density, hives_cap) do
    %ArenaMap{
      width: width,
      height: height,
      hexa_size: hexa_size,
      maze_density: maze_density
    }
    |> initialize_map(maze_density)
    |> initialize_hives(hives_cap)
  end

  defp initialize_hives(
         %ArenaMap{} = map,
         hives_cap
       ) do
    %ArenaMap{
      map
      | hives: generate_hives(hives_cap)
    }
  end

  defp generate_hives(hives_cap) do
    1..hives_cap
    |> Enum.reduce([], fn hive_no, acc ->
      hexa = ScapeUtils.get_hive_hexa(hive_no)

      acc =
        acc ++
          %{
            hexa => %Feature{
              type: "hive",
              color: "red"
            }
          }
    end)
  end

  defp initialize_map(
         %ArenaMap{
           width: width,
           height: height,
           hexa_size: hexa_size
         } = map,
         density
       ) do
    %ArenaMap{
      map
      | maze: generate_maze(width, height, hexa_size, density)
    }
  end

  defp maybe_add_wall(acc, hexa, width, height, density) do
    # Random number between 0 and width*height
    #    area_rand = :rand.uniform(width * height)
    area = width * height
    # Random number between 1 and 3
    circ_rand = :rand.uniform(2 * (width + height))

    if rem(area, circ_rand) < density do
      new_acc =
        acc ++
          %{
            hexa => %Feature{
              type: "wall",
              color: "black"
            }
          }

      new_acc
    end
  end

  def default_dimensions, do: %Vector{x: 800, y: 600, z: 0}

  defp generate_maze(width, height, hexa_size, density) do
    q_range = 0..div(width, hexa_size)
    r_range = 0..div(height, hexa_size)

    Enum.reduce(q_range, [], fn q, acc ->
      Enum.reduce(r_range, acc, fn r, acc_inner ->
        hexa = Hexa.new(q, r)

        acc_inner
        |> maybe_add_wall(hexa, width, height, density)
      end)
    end)
  end
end
