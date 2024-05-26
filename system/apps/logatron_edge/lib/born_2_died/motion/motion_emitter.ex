defmodule Born2Died.MotionEmitter do

  @moduledoc """
  Born2Died.HealthEmitter is a GenServer that manages a channel to client
  """
  alias Born2Died.Movement, as: Movement
  alias Edge.Client, as: Client
  alias Born2Died.Facts, as: LifeFacts

  require Logger

  @life_moved_v1 LifeFacts.life_moved_v1()

  ############ API ############
  def emit_life_moved(%Movement{} = movement),
    do:
      Client.publish(
        movement.edge_id,
        @life_moved_v1,
        %{movement: movement}
      )


end
