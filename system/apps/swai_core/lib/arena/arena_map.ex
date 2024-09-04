defmodule Arena.ArenaMap do
  @moduledoc """
  This module is responsible for managing the arena map in the system.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Arena.ArenaMap, as: ArenaMap
  alias Arena.Hexa, as: Hexa

  @width 800
  @height 600
  @hexa_size 4

  @all_fields [
    :width,
    :height,
    :hexa_size,
    :maze,
    :collectibles,
    :particles,
    :threats
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:width, :integer, default: @width)
    field(:height, :integer, default: @height)
    field(:hexa_size, :integer, default: @hexa_size)
    field(:maze, :map, default: %{})
    field(:collectibles, :map, default: %{})
    field(:particles, :map, default: %{})
    field(:threats, :map, default: %{})
  end

  def changeset(arena_map, attrs)
      when is_map(attrs) do
    arena_map
    |> cast(attrs, @all_fields)
    |> validate_required(@all_fields)
  end

  def generate(width, height, hexa_size, density) do
    %ArenaMap{
      width: width,
      height: height,
      hexa_size: hexa_size
    }
    |> initialize_map(density)
  end

  def initialize_map(
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
      acc
      |> Map.put(hexa, %{
        type: :wall,
        color: :black
      })
    else
      acc
    end
  end

  def generate_maze(width, height, hexa_size, density) do
    q_range = 0..div(width, hexa_size)
    r_range = 0..div(height, hexa_size)

    Enum.reduce(q_range, %{}, fn q, acc ->
      Enum.reduce(r_range, acc, fn r, acc_inner ->
        hexa = Hexa.new(q, r)

        acc_inner
        |> maybe_add_wall(hexa, width, height, density)
      end)
    end)
  end
end
