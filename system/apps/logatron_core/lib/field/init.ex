defmodule Field.Init do
  use Ecto.Schema

  @moduledoc """
  Field.Init is the struct that identifies the state of a Field.
  """
  import Ecto.Changeset

  alias Schema.Id

  alias MngFarm.Init, as: MngFarmInit
  alias Field.Init, as: FieldInit

  require Logger

  @id_prefix "field"

  @all_fields [
    :id,
    :edge_id,
    :scape_id,
    :region_id,
    :farm_id,
    :mng_farm_id,
    :rows,
    :cols,
    :depth,
    :pct_good,
    :pct_bad
  ]

  @cast_fields [
    :id,
    :edge_id,
    :scape_id,
    :region_id,
    :farm_id,
    :mng_farm_id,
    :rows,
    :cols,
    :depth,
    :pct_good,
    :pct_bad
  ]

  @required_fields [
    :id,
    :edge_id,
    :scape_id,
    :region_id,
    :farm_id,
    :mng_farm_id,
    :rows,
    :cols,
    :depth,
    :pct_good,
    :pct_bad
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:edge_id, :string)
    field(:scape_id, :string)
    field(:region_id, :string)
    field(:farm_id, :string)
    field(:mng_farm_id, :string)
    field(:cols, :integer)
    field(:rows, :integer)
    field(:depth, :integer)
    field(:pct_good, :integer)
    field(:pct_bad, :integer)
  end

  def changeset(%FieldInit{} = field_init, args)
      when is_map(args) do
    field_init
    |> cast(args, @cast_fields)
    |> validate_required(@required_fields)
  end

  def from_map(map) when is_map(map) do
    case(changeset(%FieldInit{}, map)) do
      %{valid?: true} = changeset ->
        field_init =
          changeset
          |> Ecto.Changeset.apply_changes()

        {:ok, field_init}

      changeset ->
        {:error, changeset}
    end
  end

  def from_mng_farm(depth, %MngFarmInit{} = mng_farm_init) do
    id = Id.new(@id_prefix) |> Id.as_string()
    %{farm: farm} = mng_farm_init

    res =
      %FieldInit{
        id: id,
        edge_id: mng_farm_init.edge_id,
        scape_id: mng_farm_init.scape_id,
        region_id: mng_farm_init.region_id,
        farm_id: mng_farm_init.farm_id,
        mng_farm_id: mng_farm_init.id,
        cols: farm.fields_def.x,
        rows: farm.fields_def.y,
        depth: depth,
        pct_good: mng_farm_init.farm.max_pct_good,
        pct_bad: mng_farm_init.farm.max_pct_bad
      }
    res
  end
end
