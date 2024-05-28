defmodule SwaiWeb.Dispatch.RegionHandler do

  @moduledoc """
  The RegionHandler is used to handle Edge Events related to Regions
  """

  require Logger
  alias Phoenix.PubSub

  alias Region.Facts, as: RegionFacts

  @initializing_region_v1 RegionFacts.initializing_region_v1()
  @region_initialized_v1 RegionFacts.region_initialized_v1()

  def pub_initializing_region_v1(payload, socket) do
    Logger.info("Initializing Region: #{inspect(payload)}")
    {:ok, region_init} = Region.Init.from_map(payload["region_init"])
    PubSub.broadcast!(
      Swai.PubSub,
      @initializing_region_v1,
      {@initializing_region_v1, region_init}
    )
    {:noreply, socket}
  end

  def pub_region_initialized_v1(payload, socket) do
    Logger.info("Region Initialized: #{inspect(payload)}")
    {:ok, region_init} = Region.Init.from_map(payload["region_init"])
    PubSub.broadcast!(
      Swai.PubSub,
      @region_initialized_v1,
      {@region_initialized_v1, region_init}
    )
    {:noreply, socket}
  end



end
