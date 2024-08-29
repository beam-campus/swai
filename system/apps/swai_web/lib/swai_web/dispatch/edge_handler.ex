defmodule SwaiWeb.Dispatch.EdgeHandler do
  @moduledoc """
  The EdgeHandler is used to broadcast messages to all clients
  """

  
  alias Edge.Facts, as: EdgeFacts
  alias Scape.Facts, as: ScapeFacts
  alias Phoenix.PubSub, as: PubSub
  alias Edge.Init, as: EdgeInit
  alias TrainSwarmProc.CommandedApp, as: TrainSwarmApp
  alias TrainSwarmProc.DetachScape.CmdV1, as: DetachScape
  # alias SwarmLicenses.Service, as: Licenses
  alias Scapes.Service, as: Scapes

  require Logger

  @edge_facts EdgeFacts.edge_facts()
  @scape_facts ScapeFacts.scape_facts()
  @edge_detached_v1 EdgeFacts.edge_detached_v1()
  @edge_attached_v1 EdgeFacts.edge_attached_v1()
  @scape_detached_v1 ScapeFacts.scape_detached_v1()

  ################ CALLBACKS ################
  def pub_edge_detached(payload) do
    case EdgeInit.from_map(payload["edge_init"]) do
      {:ok, edge_init} ->
        Logger.debug("pub_edge_detached #{inspect(edge_init)}")

        Swai.PubSub
        |> PubSub.broadcast!(@edge_facts, {@edge_detached_v1, edge_init})

        detach_scapes(edge_init.id)

      {:error, _} ->
        Logger.error("pub_edge_detached: invalid edge_init")
    end
  end

  defp detach_scapes(edge_id) do
    case Scapes.get_for_edge(edge_id) do
      [] ->
        Logger.error("detach_scapes: no scapes found for edge_id: #{edge_id}")
        []

      scapes ->
        Enum.each(scapes, fn scape ->
          detach_scape = %DetachScape{
            agg_id: scape.license_id,
            version: 1,
            payload: scape
          }

          TrainSwarmApp.dispatch(detach_scape)

          Swai.PubSub
          |> PubSub.broadcast!(@scape_facts, {@scape_detached_v1, scape})
        end)

        scapes
    end
  end

  def pub_edge_attached(payload, socket) do
    Logger.info("pub_edge_attached #{inspect(payload)}")
    {:ok, edge_init} = EdgeInit.from_map(payload["edge_init"])

    edge_init =
      %Edge.Init{
        edge_init
        | socket: socket
      }

    Swai.PubSub
    |> PubSub.broadcast!(
      @edge_facts,
      {@edge_attached_v1, edge_init}
    )

    {:noreply, socket}
  end
end
