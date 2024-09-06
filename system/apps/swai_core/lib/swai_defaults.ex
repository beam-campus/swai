defmodule Swai.Defaults do
  @moduledoc """
  Swai.Defaults contains the default values for the Swai system.
  """
  alias Schema.Vector, as: Vector

  def standard_cost_in_tokens, do: 3_000
  def arena_width, do: 800
  def arena_height, do: 600
  def arena_depth, do: 0
  def arena_hive_offset, do: 100
  def arena_hexa_size, do: 5
  def arena_maze_density, do: 100
  def hives_cap, do: 4
  def scapes_cap, do: 10
  def particles_cap, do: 1_000
  def threats_cap, do: 10
  def collectibles_cap, do: 10

  def arena_dimensions, do: Vector.new(arena_width(), arena_height(), arena_depth())
end
