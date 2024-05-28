defmodule Born2Died.State do
  use Ecto.Schema

  @moduledoc """
  The Life State are the parameters
  that are used as the state structure for a Life Worker
  """

  import Ecto.Changeset

  alias Schema.Id, as: Id
  alias Schema.Vitals, as: Vitals
  alias Schema.Life, as: Life
  alias Schema.Vector, as: Vector

  alias MngFarm.Init, as: MngFarmInit

  require Logger

  defguard is_born_2_died_state(state)
           when is_struct(state, __MODULE__)

  @id_prefix "born2died"

  @status %{
    unknown: 0,
    initialized: 1,
    alive: 2,
    infected: 4,
    pregnant: 8,
    dead: 16,
    in_heat: 32,
    in_cool: 64,
    wounded: 128
  }

  @all_fields [
    :id,
    :edge_id,
    :scape_id,
    :region_id,
    :farm_id,
    :mng_farm_id,
    :ticks,
    :status,
    :world_dimensions,
    :life,
    :pos,
    :vitals
  ]

  @flat_fields [
    :id,
    :edge_id,
    :scape_id,
    :region_id,
    :farm_id,
    :mng_farm_id,
    :ticks,
    :status
  ]

  def status, do: @status

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:edge_id, :string)
    field(:scape_id, :string)
    field(:region_id, :string)
    field(:farm_id, :string)
    field(:mng_farm_id, :string)
    field(:ticks, :integer)
    field(:status, :string)
    embeds_one(:world_dimensions, Vector)
    embeds_one(:life, Life)
    embeds_one(:pos, Vector)
    embeds_one(:vitals, Vitals)
  end

  # def random(edge_id, scape_id, region_id, farm_id, %{x: max_x, y: max_y, z: z} = _vector, life) do
  #   %Born2Died.State{
  #     id: Id.new(@id_prefix) |> Id.as_string(),
  #     edge_id: edge_id,
  #     scape_id: scape_id,
  #     region_id: region_id,
  #     farm_id: farm_id,
  #     field_id: Id.new("field", to_string(z)) |> Id.as_string(),
  #     life: life,
  #     pos: Vector.random(max_x, max_y, 1),
  #     vitals: Vitals.random(),
  #     status: "unknown",
  #     ticks: 0,
  #     status: 0
  #   }
  # end

  def from_life(%Life{} = life, %MngFarmInit{} = mng_farm_init) do
    %Born2Died.State{
      id: Id.new(@id_prefix) |> Id.as_string(),
      edge_id: mng_farm_init.edge_id,
      scape_id: mng_farm_init.scape_id,
      region_id: mng_farm_init.region_id,
      farm_id: mng_farm_init.farm.id,
      mng_farm_id: mng_farm_init.id,
      life: life,
      world_dimensions:
        Vector.new(mng_farm_init.max_col, mng_farm_init.max_row, mng_farm_init.max_depth),
      pos: Vector.random(mng_farm_init.max_col, mng_farm_init.max_row, mng_farm_init.max_depth),
      vitals: Vitals.random(),
      ticks: 0,
      status: "unknown"
    }
  end

  def changeset(state, args) when is_map(args) do
    state
    |> cast(args, @flat_fields)
    |> cast_embed(:world_dimensions, with: &Vector.changeset/2, required: true)
    |> cast_embed(:life, with: &Life.changeset/2, required: true)
    |> cast_embed(:pos, with: &Vector.changeset/2, required: true)
    |> cast_embed(:vitals, with: &Vitals.changeset/2, required: true)
    |> validate_required(@all_fields)
  end

  def from_map(map) when is_map(map) do
    case(changeset(%Born2Died.State{}, map)) do
      %{valid?: true} = changeset ->
        state =
          changeset
          |> Ecto.Changeset.apply_changes()

        {:ok, state}

      changeset ->
        {:error, changeset}
    end
  end

  ############## IMPLEMENTATIONS ##############
  defimpl String.Chars, for: __MODULE__ do
    def to_string(s) do
      "\n\n [#{__MODULE__}]\n" <>
        "#{s.life}" <>
        "#{s.vitals}\n\n"
    end
  end
end
