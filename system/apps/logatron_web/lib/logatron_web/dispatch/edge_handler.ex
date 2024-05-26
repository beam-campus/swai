defmodule LogatronWeb.Dispatch.EdgeHandler do

  @moduledoc """
  The EdgeHandler is used to broadcast messages to all clients
  """

  require Logger
  alias Edge.Facts, as: EdgeFacts
  alias Phoenix.PubSub

  @edge_detached_v1 EdgeFacts.edge_detached_v1()
  @edge_attached_v1 EdgeFacts.edge_attached_v1()

  ################ CALLBACKS ################

  def pub_edge_detached(payload) do

    {:ok, edge_init} = Edge.Init.from_map(payload["edge_init"])

    PubSub.broadcast!(
      Logatron.PubSub,
      @edge_detached_v1,
      {@edge_detached_v1, edge_init}
    )
  end

  def pub_edge_attached(payload) do
    {:ok, edge_init} = Edge.Init.from_map(payload["edge_init"])

    PubSub.broadcast!(
      Logatron.PubSub,
      @edge_attached_v1,
      {@edge_attached_v1, edge_init}
    )
  end
end
