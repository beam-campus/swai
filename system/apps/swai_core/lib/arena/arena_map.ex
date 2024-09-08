defmodule Arena.ArenaMap do
  @moduledoc """
  This module is responsible for managing the arena map in the system.
  """

  use Ecto.Schema
  import Ecto.Changeset

  require Logger

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
    # :maze,
    # :collectibles,
    # :particles,
    # :threats,
    # :hives,
    :elements
  ]

  @flat_fields [
    :width,
    :height,
    :hexa_size,
    :maze_density
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:width, :integer, default: @map_width)
    field(:height, :integer, default: @map_height)
    field(:hexa_size, :integer, default: @map_hexa_size)
    field(:maze_density, :integer, default: @maze_density)
    # field(:maze, {:array, :map}, default: [])
    # field(:collectibles, {:array, :map}, default: [])
    # field(:particles, {:array, :map}, default: [])
    # field(:threats, {:array, :map}, default: [])
    # field(:hives, {:array, :map}, default: [])
    embeds_many(:elements, Arena.Element, on_replace: :delete)
  end

  def changeset(arena_map, attrs)
      when is_map(attrs) do
    arena_map
    |> cast(attrs, @flat_fields)
    |> cast_embed(:elements, with: &Arena.Element.changeset/2)
    |> validate_required(@all_fields)
  end

  def generate(width, height, hexa_size, maze_density, hives_cap) do
    %ArenaMap{
      width: width,
      height: height,
      hexa_size: hexa_size,
      maze_density: maze_density,
      elements: []
    }
    |> initialize_maze(maze_density)
    |> initialize_hives(hives_cap)

    #    |> initialize_hives(hives_cap)
  end

  defp initialize_hives(map, hives_cap) do
    %ArenaMap{
      map
      | elements: map.elements |> generate_hives(hives_cap)
    }
  end

  def generate_hives(elements, hives_cap) do
    1..hives_cap
    |> Enum.reduce(elements, fn hive_no, acc ->
      hexa = ScapeUtils.get_hive_hexa(hive_no)

      [
        %Arena.Element{
          hexa: hexa,
          feature: %Feature{
            type: "hive",
            color: "red"
          }
        }
        | acc
      ]
    end)
  end

  defp initialize_maze(
         %ArenaMap{
           width: width,
           height: height,
           hexa_size: hexa_size
         } = map,
         density
       ) do
    %ArenaMap{
      map
      | elements:
          map.elements
          |> generate_maze(width, height, hexa_size, density)
    }
  end

  defp maybe_add_wall(acc, hexa, width, height, density) do
    area_rand = :rand.uniform(width * height * :rand.uniform(7))
    circ_rand = :rand.uniform(:rand.uniform(3) * (width + height))

    if rem(area_rand, circ_rand) < density do
      [
        %Arena.Element{
          hexa: hexa,
          feature: %Feature{
            type: "wall",
            color: "black"
          }
        }
        | acc
      ]
    else
      acc
    end
  end

  def default_dimensions, do: %Vector{x: 800, y: 600, z: 0}

  def generate_maze(elements, width, height, hexa_size, density) do
    q_range = 0..div(width, hexa_size)
    r_range = 0..div(height, hexa_size)

    Enum.reduce(q_range, elements, fn q, acc ->
      Enum.reduce(r_range, acc, fn r, acc_inner ->
        hexa = Hexa.new(q, r)

        acc_inner
        |> maybe_add_wall(hexa, width, height, density)
      end)
    end)
  end
end
