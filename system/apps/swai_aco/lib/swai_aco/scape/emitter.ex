defmodule Scape.Emitter do
  # use GenServer, restart: :transient

  @moduledoc """
  Scape.Emitter is a GenServer that manages a channel to a scape,
  """

  alias Scape.Init, as: ScapeInit
  alias Region.Init, as: RegionInit
  alias Edge.Client, as: Client
  alias Region.Facts, as: RegionFacts

  require Logger

  @initializing_region_v1 RegionFacts.initializing_region_v1()
  @region_initialized_v1 RegionFacts.region_initialized_v1()

  ######### API #############

  def emit_initializing_region(%RegionInit{} = region_init),
    do:
      Client.publish(
        region_init.edge_id,
        @initializing_region_v1,
        %{region_init: region_init}
      )

  def emit_region_initialized(%RegionInit{} = region_init),
    do:
      Client.publish(
        region_init.edge_id,
        @region_initialized_v1,
        %{region_init: region_init}
      )

  # def emit_initializing_region(%RegionInit{} = region_init),
  #   do:
  #     GenServer.cast(
  #       via(region_init.scape_id),
  #       {:emit_initializing_region, region_init}
  #     )

  # def emit_region_initialized(%RegionInit{} = region_init),
  #   do:
  #     GenServer.cast(
  #       via(region_init.scape_id),
  #       {:emit_region_initialized, region_init}
  #     )

  ######## CALLBACKS ########

  # @impl GenServer
  # def handle_cast({:emit_initializing_region, %RegionInit{} = region_init}, state) do
  #   EdgeClient.publish(
  #     region_init.edge_id,
  #     @initializing_region_v1, %{region_init: region_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl GenServer
  # def handle_cast({:emit_region_initialized, %RegionInit{} = region_init}, state) do
  #   EdgeClient.publish(
  #     region_init.edge_id,
  #     @region_initialized_v1, %{region_init: region_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl GenServer
  # def init(%ScapeInit{} = scape_init),
  #   do: {:ok, scape_init}

  # ##### PLUMBING #####
  # defp to_name(scape_id),
  #   do: "scape.emitter.#{scape_id}"

  # def via(scape_id),
  #   do: Swai.Registry.via_tuple({:scape_channel, to_name(scape_id)})

  # def start_link(%ScapeInit{} = scape_init) do
  #   GenServer.start_link(
  #     __MODULE__,
  #     scape_init,
  #     name: via(scape_init.id)
  #   )
  # end
end
