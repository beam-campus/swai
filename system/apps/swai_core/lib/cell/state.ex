defmodule Cell.State do
  @moduledoc """
  Cell.State is the struct that identifies the state of a Cell.
  """
  use Ecto.Schema

  alias Born2Died.State, as: LifeState
  alias Field.Effect, as: Effect
  alias Cell.State, as: CellState

  import Ecto.Changeset

  require Logger

  @all_fields [
    :prev_col,
    :prev_row,
    :prev_depth,
    :col,
    :row,
    :depth,
    :content,
    :class,
    :edge_id,
    :scape_id,
    :region_id,
    :mng_farm_id,
    :occupants,
    :effects
  ]

  @flat_fields [
    :id
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:prev_col, :integer)
    field(:prev_row, :integer)
    field(:prev_depth, :integer)
    field(:col, :integer)
    field(:row, :integer)
    field(:depth, :integer)
    field(:content, :string)
    field(:class, :string)
    field(:edge_id, :string)
    field(:scape_id, :string)
    field(:region_id, :string)
    field(:mng_farm_id, :string)
    embeds_many(:occupants, LifeState)
    embeds_many(:effects, Effect)
  end

  def changeset(cell, args) when is_map(args) do
    cell
    |> cast(args, @flat_fields)
    |> validate_required(@all_fields)
  end

  def from_life(%LifeState{} = life) do
    %CellState{
      prev_col: life.prev_pos.x,
      prev_row: life.prev_pos.y,
      prev_depth: life.prev_pos.z,
      col: life.pos.x,
      row: life.pos.y,
      depth: life.pos.z,
      content: CellState.content_from_life(life),
      class: CellState.class_from_life(life),
      edge_id: life.edge_id,
      scape_id: life.scape_id,
      region_id: life.region_id,
      mng_farm_id: life.mng_farm_id,
      occupants: [],
      effects: []
    }
  end

  def content_from_life(%LifeState{} = life) do
    case life.life.gender do
      #  "male" -> "♂"
      "male" -> "\u{1F402}"
      #  "female" -> "♀"
      "female" -> "\u{1F404}"
      _ -> "?"
    end
  end

  def class_from_life(%LifeState{} = _life) do
    "sw-life"
  end
end
