defmodule Cell.Init do
  use Ecto.Schema

  @moduledoc """
  Cell.Init is the struct that identifies the state of a Cell.
  """

  alias Schema.Vector, as: Vector
  alias Schema.Id, as: Id

  alias Cell.Init, as: CellInit

  import Ecto.Changeset

  require Logger

  @id_prefix "cell"

  @all_fields [
    :id,
    :edge_id,
    :scape_id,
    :region_id,
    :farm_id,
    :field_id
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:edge_id, :string)
    field(:scape_id, :string)
    field(:region_id, :string)
    field(:farm_id, :string)
    field(:field_id, :string)
    field(:row, :integer)
    field(:col, :integer)
    field(:depth, :integer)
    embeds_many(:actors, :any)
    embeds_many(:occupants, :any)
  end

  def from_field_init(field_init, row, col, depth) do
    id = Id.new(@id_prefix) |> Id.as_string()
    %CellInit{
      id: id,
      edge_id: field_init.edge_id,
      scape_id: field_init.scape_id,
      region_id: field_init.region_id,
      farm_id: field_init.farm_id,
      field_id: field_init.id,
      row: row,
      col: col,
      depth: depth,
      actors: [],
      occupants: []
    }
  end
end
