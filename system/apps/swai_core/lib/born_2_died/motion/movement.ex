defmodule Born2Died.Movement do
  use Ecto.Schema

  alias Schema.Vector, as: Vector
  alias Born2Died.MotionState, as: MotionState
  alias Schema.Life, as: Life

  import Ecto.Changeset

  @moduledoc """
  the payload for the edge:attached:v1 fact
  """
  @all_fields [
    :born2died_id,
    :mng_farm_id,
    :edge_id,
    :life,
    :from,
    :to,
    :heading,
    :delta_t
  ]

  @required_fields [
    :born2died_id,
    :mng_farm_id,
    :edge_id,
    :life,
    :from,
    :to,
    :heading,
    :delta_t
  ]

  @flat_fields [
    :edge_id,
    :mng_farm_id,
    :born2died_id,
    :heading,
    :delta_t
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:born2died_id, :string)
    field(:edge_id, :string)
    field(:mng_farm_id, :string)
    field(:delta_t, :integer)
    field(:heading, :float)
    embeds_one(:to, Vector)
    embeds_one(:from, Vector)
    embeds_one(:life, Life)
  end

  def from_born2died(%MotionState{} = motion, %Vector{} = to, delta_t),
    do: %__MODULE__{
      born2died_id: motion.born2died_id,
      edge_id: motion.edge_id,
      mng_farm_id: motion.mng_farm_id,
      life: motion,
      from: motion.pos,
      to: to,
      heading: Euclid2D.heading(motion.pos, to),
      delta_t: delta_t
    }

  def from_map(map) when is_map(map) do
    case changeset(%__MODULE__{}, map) do
      %{valid?: true} = changeset ->
        state =
          changeset
          |> Ecto.Changeset.apply_changes()

        {:ok, state}

      changeset ->
        {:error, changeset}
    end
  end



  def changeset(%__MODULE__{} = movement, map) when is_map(map) do
    movement
    |> cast(map, @flat_fields)
    |> cast_embed(:to, with: &Vector.changeset/2)
    |> cast_embed(:from, with: &Vector.changeset/2)
    |> cast_embed(:life, with: &Life.changeset/2)
    |> validate_required(@all_fields)
  end
end
