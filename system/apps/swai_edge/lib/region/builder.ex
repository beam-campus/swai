defmodule Region.Builder do
  use GenServer

  @moduledoc """
  Region.Builder is a GenServer that constructs an Swai.Region
  by spawning Swai.MngFarm Processes.
  """

  alias MngFarm.Init, as: FarmInit
  alias Region.Init, as: RegionInit

  require Logger

  ############# CALLBACKS ############
  @impl GenServer
  def init(%RegionInit{} = region_init) do
    Logger.info("region.builder: #{Colors.region_theme(self())}")
    {:ok, start_farms(region_init)}
  end


  ############# INTERNALS ############
  defp start_farms(%RegionInit{} = region_init) do
    Enum.to_list(1..region_init.nbr_of_farms)
    |> Enum.map(& farm_from_region(&1, region_init))
    |> Enum.each(fn farm_init -> Region.Farms.start_farm(region_init.id, farm_init) end)
    region_init
  end

  defp farm_from_region(_, region_init),
  do:
    FarmInit.from_region(region_init)

  ################# PLUMBING ################
  def to_name(key),
    do: "region.builder.#{key}"

  def via(region_id),
    do: Edge.Registry.via_tuple({:region_builder, to_name(region_id)})

  def child_spec(%RegionInit{id: region_id} = region_init) do
    %{
      id: to_name(region_id),
      start: {__MODULE__, :start_link, [region_init]},
      restart: :temporary,
      type: :worker
    }
  end

  def start_link(%RegionInit{id: region_id} = region_init),
    do:
      GenServer.start_link(
        __MODULE__,
        region_init,
        name: via(region_id)
      )
end
