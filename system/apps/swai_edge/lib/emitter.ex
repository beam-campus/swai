defmodule Edge.Emitter do
  # use GenServer, restart: :transient

  @moduledoc """
  Edge.Emitter is a GenServer that manages a channel to a scape,
  """

  alias Edge.Client
  alias Scape.Init, as: ScapeInit
  alias Scape.Facts, as: ScapeFacts


  require Logger

  # @attach_scape_v1 "attach_scape:v1"

  @initializing_scape_v1 ScapeFacts.initializing_scape_v1()
  @scape_initialized_v1 ScapeFacts.scape_initialized_v1()
  @scape_detached_v1 ScapeFacts.scape_detached_v1()

  def emit_initializing_scape(scape_init),
    do:
    Client.publish(
      scape_init.edge_id,
      @initializing_scape_v1,
      %{scape_init: scape_init}
    )


  # def emit_initializing_scape(%ScapeInit{} = scape_init),
  #   do:
  #     GenServer.cast(
  #       via(scape_init.id),
  #       {:initializing_scape, scape_init}
  #     )

  def emit_scape_initialized(scape_init),
    do:
    Client.publish(
      scape_init.edge_id,
      @scape_initialized_v1,
      %{scape_init: scape_init}
    )


  # def emit_scape_initialized(%ScapeInit{} = scape_init),
  #   do:
  #     GenServer.cast(
  #       via(scape_init.id),
  #       {:scape_initialized, scape_init}
  #     )

  def scape_detached(scape_init),
    do:
    Client.publish(
      scape_init.edge_id,
      @scape_detached_v1,
      %{scape_init: scape_init}
    )

  # def scape_detached(%ScapeInit{} = scape_init),
  #   do:
  #     GenServer.cast(
  #       via(scape_init.id),
  #       {:scape_detached, scape_init}
  #     )

  ########### CALLBACKS ################

  # @impl true
  # def handle_cast({:scape_detached, %ScapeInit{} = scape_init}, state) do
  #   Client.publish(
  #     scape_init.edge_id,
  #     @scape_detached_v1,
  #     %{scape_init: scape_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl true
  # def handle_cast({:initializing_scape, %ScapeInit{} = scape_init}, state) do

  #   Logger.error("Publishing: initializing_scape: #{scape_init.id}")

  #   Client.publish(
  #     scape_init.edge_id,
  #     @initializing_scape_v1,
  #     %{scape_init: scape_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl true
  # def handle_cast({:scape_initialized, %ScapeInit{} = scape_init}, state) do

  #   Client.publish(
  #     scape_init.edge_id,
  #     @scape_initialized_v1,
  #     %{scape_init: scape_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl true
  # def init(scape_init) do
  #   Logger.info("edge.emitter:  #{Colors.edge_theme(self())}")
  #   {:ok, scape_init}
  # end

  # ############### PLUMBING ##############
  # def child_spec(%ScapeInit{} = scape_init),
  #   do: %{
  #     id: via(scape_init.id),
  #     start: {__MODULE__, :start_link, [scape_init]},
  #     type: :worker
  #   }

  # def to_name(key) when is_bitstring(key),
  #   do: "edge.emitter.#{key}"

  # def via(scape_init_id),
  #   do: Edge.Registry.via_tuple({:edge_emitter, to_name(scape_init_id)})

  # def start_link(scape_init),
  #   do:
  #     GenServer.start_link(
  #       __MODULE__,
  #       scape_init,
  #       name: via(scape_init.id)
  #     )
end
