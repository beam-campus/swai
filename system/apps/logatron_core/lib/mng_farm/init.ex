defmodule MngFarm.Init do
  use Ecto.Schema
  @moduledoc """
  MngFarm.Init is the struct that identifies the state of a Farm.
  """


  @id_prefix "mng_farm"

  alias MngFarm.Init, as: FarmInit
  alias Schema.Id, as: Id
  alias Schema.Farm, as: Farm

  import Ecto.Changeset

  require Logger

  @all_fields [
    :id,
    :edge_id,
    :region_id,
    :scape_id,
    :country,
    :farm_id,
    :max_row,
    :max_col,
    :max_depth,
    :farm
  ]

  @cast_fields [
    :id,
    :edge_id,
    :region_id,
    :scape_id,
    :farm_id,
    :max_row,
    :max_col,
    :max_depth,
    :country
  ]

  @required_fields [
    :id,
    :edge_id,
    :region_id,
    :scape_id,
    :country,
    :farm_id,
    :max_row,
    :max_col,
    :max_depth,
    :farm
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:edge_id, :string)
    field(:scape_id, :string)
    field(:region_id, :string)
    field(:country, :string)
    field(:farm_id, :string)
    field(:max_row, :integer)
    field(:max_col, :integer)
    field(:max_depth, :integer)
    embeds_one(:farm, Farm)
  end

  def from_region(region_init) do
    farm = Schema.Farm.random()

    %FarmInit{
      id: Id.new(@id_prefix) |> Id.as_string(),
      edge_id: region_init.edge_id,
      region_id: region_init.id,
      scape_id: region_init.scape_id,
      country: region_init.name,
      farm_id: farm.id,
      max_col: farm.fields_def.x,
      max_row: farm.fields_def.y,
      max_depth: farm.fields_def.z,
      farm: farm
    }
  end

  def changeset(mng_farm, args)
      when is_map(args) do
    mng_farm
    |> cast(args, @cast_fields)
    |> cast_embed(:farm, with: &Farm.changeset/2)
    |> validate_required(@required_fields)
  end

  def from_map(map) when is_map(map) do
    case(changeset(%FarmInit{}, map)) do
      %{valid?: true} = changeset ->
        mng_farm_init =
          changeset
          |> Ecto.Changeset.apply_changes()

        {:ok, mng_farm_init}

      changeset ->
        {:error, changeset}
    end
  end
end
