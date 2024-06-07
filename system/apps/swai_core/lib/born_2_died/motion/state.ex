defmodule Born2Died.MotionState do
  use Ecto.Schema

  @moduledoc """
  Born2Died.MotionState is a schema that represents the state of a life
  """
  alias Schema.Vector, as: Vector
  alias Born2Died.State, as: LifeState
  alias Born2Died.MotionState, as: MotionState

  require Jason.Encoder

  @all_fields [
    :born2died_id,
    :edge_id,
    :mng_farm_id,
    :life,
    :pos,
    :world_dimensions
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:born2died_id, :string)
    field(:edge_id, :string)
    field(:mng_farm_id, :string)
    embeds_one(:life, LifeState)
    embeds_one(:pos, Vector)
    embeds_one(:world_dimensions, Vector)
  end

  def from_life_state(%LifeState{} = life_init) do
    %MotionState{
      born2died_id: life_init.id,
      edge_id: life_init.edge_id,
      mng_farm_id: life_init.mng_farm_id,
      life: life_init,
      pos: life_init.pos,
      world_dimensions: life_init.world_dimensions
    }
  end
end
