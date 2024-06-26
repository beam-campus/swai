defmodule Born2Died.BreedingChannel do

  @moduledoc """
  Born2Died.BreedingChannel is used to emit breeding events both internally and upstream
  """

  alias Born2Died.Facts, as: LifeFacts
  alias Phoenix.PubSub, as: Exchange
  alias Edge.Client, as: Upstream

  @is_mating_v1 LifeFacts.is_mating_v1()


  def emit_mating(%Mating.Payload{} = payload) do
    Exchange.broadcast!(
      Edge.PubSub,
      @is_mating_v1,
      {@is_mating_v1, payload}
    )

    Upstream.publish(
      payload.edge_id,
      @is_mating_v1,
      %{mating: payload}
    )
  end


end
