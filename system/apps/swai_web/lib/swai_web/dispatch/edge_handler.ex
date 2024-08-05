defmodule SwaiWeb.Dispatch.EdgeHandler do

  @moduledoc """
  The EdgeHandler is used to broadcast messages to all clients
  """

  alias Edge.Facts,  as: EdgeFacts
  alias Phoenix.PubSub,  as: PubSub
  alias Edge.Init,  as: EdgeInit

  require Logger

  @edge_detached_v1 EdgeFacts.edge_detached_v1()
  @edge_attached_v1 EdgeFacts.edge_attached_v1()

  ################ CALLBACKS ################

  def pub_edge_detached(payload) do

    Logger.info("pub_edge_detached #{inspect(payload)}")
    {:ok, edge_init} = EdgeInit.from_map(payload["edge_init"])

    # Logger.debug("pub_edge_detached #{inspect(edge_init)}")

    PubSub.broadcast!(
      Swai.PubSub,
      @edge_detached_v1,
      {@edge_detached_v1, edge_init}
    )
  end

  def pub_edge_attached(payload, socket) do
    Logger.info("pub_edge_attached #{inspect(payload)}")
    {:ok, edge_init} = EdgeInit.from_map(payload["edge_init"])
    edge_init = %EdgeInit{
      edge_init |
      socket: socket
    }

    # Logger.debug("pub_edge_attached #{inspect(edge_init)}")

    PubSub.broadcast!(
      Swai.PubSub,
      @edge_attached_v1,
      {@edge_attached_v1, edge_init}
    )
  end
end
