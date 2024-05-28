defmodule Region.Emitter do
  # use GenServer, restart: :transient

  @moduledoc """
  Region.Emitter is a GenServer that manages a channel to a region,
  """

  alias MngFarm.Facts, as: FarmFacts
  alias MngFarm.Init, as: MngFarmInit
  alias Edge.Client, as: EdgeClient

  require Logger

  @initializing_farm_v1 FarmFacts.initializing_farm_v1()
  @farm_initialized_v1 FarmFacts.farm_initialized_v1()

  def emit_initializing_farm(%MngFarmInit{} = farm_init),
    do:
      EdgeClient.publish(
        farm_init.edge_id,
        @initializing_farm_v1,
        %{farm_init: farm_init}
      )

  def emit_farm_initialized(%MngFarmInit{} = farm_init),
    do:
      EdgeClient.publish(
        farm_init.edge_id,
        @farm_initialized_v1,
        %{farm_init: farm_init}
      )

  def emit_farm_detached(%MngFarmInit{} = farm_init),
    do:
      EdgeClient.publish(
        farm_init.edge_id,
        FarmFacts.farm_detached_v1(),
        %{farm_init: farm_init}
      )

  # #################### API ####################
  # def emit_initializing_farm_v1(%MngFarmInit{} = farm_init),
  #   do:
  #     GenServer.cast(
  #       via(farm_init.region_id),
  #       {:initializing_farm_v1, farm_init}
  #     )

  # def emit_farm_initialized_v1(%MngFarmInit{} = farm_init),
  #   do:
  #     GenServer.cast(
  #       via(farm_init.region_id),
  #       {:farm_initialized_v1, farm_init}
  #     )

  # def emit_farm_detached(%MngFarmInit{} = farm_init),
  #   do:
  #     GenServer.cast(
  #       via(farm_init.region_id),
  #       {:farm_detached_v1, farm_init}
  #     )

  # ############## CALLBACKS ##############

  # @impl GenServer
  # def handle_cast({:initializing_farm_v1, %MngFarmInit{} = farm_init}, state) do
  #   EdgeClient.publish(
  #     farm_init.edge_id,
  #     @initializing_farm_v1,
  #     %{farm_init: farm_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl GenServer
  # def handle_cast({:farm_initialized_v1, %MngFarmInit{} = farm_init}, state) do
  #   EdgeClient.publish(
  #     farm_init.edge_id,
  #     @farm_initialized_v1,
  #     %{farm_init: farm_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl GenServer
  # def handle_cast({:farm_detached_v1, %MngFarmInit{} = farm_init}, state) do
  #   EdgeClient.publish(
  #     farm_init.edge_id,
  #     FarmFacts.farm_detached_v1(),
  #     %{farm_init: farm_init}
  #   )

  #   {:noreply, state}
  # end

  # @impl GenServer
  # def init(%RegionInit{} = region_init) do
  #   Logger.info("region.emitter: #{Colors.region_theme(self())}")
  #   {:ok, region_init}
  # end

  # #################### PLUMBING ####################
  # def via(region_id),
  #   do: Edge.Registry.via_tuple(to_name(region_id))

  # def to_name(region_id),
  #   do: "region.emitter.#{region_id}"

  # def start_link(%RegionInit{} = region_init),
  #   do:
  #     GenServer.start_link(
  #       __MODULE__,
  #       region_init,
  #       name: via(region_init.id)
  #     )

  # def child_spec(%RegionInit{} = region_init),
  #   do: %{
  #     id: to_name(region_init.id),
  #     start: {__MODULE__, :start_link, [region_init]},
  #     type: :worker,
  #     restart: :transient
  #   }
end
