defmodule Born2Died.Movement do
  use Ecto.Schema

  alias Schema.Vector, as: Vector
  alias Born2Died.MotionState, as: MotionState

  import Ecto.Changeset

  @moduledoc """
  the payload for the edge:attached:v1 fact
  """

  @all_fields [
    :born2died_id,
    :edge_id,
    :to,
    :delta_t
  ]

  @flat_fields [
    :edge_id,
    :born2died_id,
    :delta_t
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:born2died_id, :string)
    field(:edge_id, :string)
    embeds_one(:to, Vector)
    field(:delta_t, :integer)
  end

  def from_born2died(%MotionState{} = life, %Vector{} = to, delta_t),
    do: %__MODULE__{
      born2died_id: life.born2died_id,
      edge_id: life.edge_id,
      to: to,
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

  def random(%MotionState{} = life) do
    %__MODULE__{
      edge_id: life.edge_id,
      born2died_id: life.born2died_id,
      to: Vector.new_position(life.pos, life.world_dimensions),
      delta_t: :rand.uniform(10)
    }
  end

  def changeset(%__MODULE__{} = movement, map) when is_map(map) do
    movement
    |> cast(map, @flat_fields)
    |> cast_embed(:to, with: &Vector.changeset/2)
    |> validate_required(@all_fields)
  end
end
