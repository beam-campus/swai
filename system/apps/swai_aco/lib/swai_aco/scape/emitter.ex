defmodule Scape.Emitter do
  use GenServer, restart: :transient

  @moduledoc """
  Scape.Emitter is a GenServer that manages a channel to a scape,
  """

  alias Scape.Init, as: ScapeInit
  alias Edge.Client, as: Client
  alias Scape.Facts, as: ScapeFacts

  @scape_detached_v1 ScapeFacts.scape_detached_v1()

  require Logger


  ######### API #############
  def emit_scape_detached(edge_id, %ScapeInit{} = scape_init),
  do:
    Client.publish(
      edge_id,
      @scape_detached_v1,
      %{scape_init: scape_init}
    )


  @impl GenServer
  def init(%ScapeInit{} = scape_init)  do
    Logger.debug("scape.emitter is up: #{Colors.scape_theme(self())} id: #{scape_init.id}")
    {:ok, scape_init}
  end

  ##### PLUMBING #####
  defp to_name(scape_id),
    do: "scape.emitter.#{scape_id}"

  def via(scape_id),
    do: Swai.Registry.via_tuple({:scape_channel, to_name(scape_id)})

  def start_link(%ScapeInit{} = scape_init) do
    GenServer.start_link(
      __MODULE__,
      scape_init,
      name: via(scape_init.id)
    )
  end
end
