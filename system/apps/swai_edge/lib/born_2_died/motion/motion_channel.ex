defmodule Born2Died.MotionEmitter do
  @moduledoc """
  Born2Died.HealthChannel is a GenServer that manages a channel to client
  """
  alias Born2Died.Movement, as: Movement
  alias Edge.Client, as: Client
  alias Born2Died.Facts, as: LifeFacts
  alias Phoenix.PubSub, as: Exchange

  require Logger

  @life_moved_v1 LifeFacts.life_moved_v1()

  ############ API ############
  def emit_life_moved(%Movement{} = movement) do
    Exchange.broadcast!(
      Edge.PubSub,
      @life_moved_v1,
      {@life_moved_v1, movement}
    )

    Client.publish(
      movement.edge_id,
      @life_moved_v1,
      %{movement: movement}
    )
  end
end
