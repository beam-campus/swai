defmodule SwaiWeb.Dispatch.FarmHandler do

  @moduledoc """
  The FarmHandler is used publish Farm Events to PubSub
  """

  alias MngFarm.Facts, as: FarmFacts
  alias MngFarm.Init, as: FarmInit



  @initializing_farm_v1 FarmFacts.initializing_farm_v1()
  @farm_initialized_v1 FarmFacts.farm_initialized_v1()
  @farm_detached_v1 FarmFacts.farm_detached_v1()

  require Logger

  def pub_initializing_farm_v1(payload, socket) do
    Logger.info("Initializing Farm: #{inspect(payload)}")
    {:ok, farm_init} = FarmInit.from_map(payload["farm_init"])

    Phoenix.PubSub.broadcast!(
      Swai.PubSub,
      @initializing_farm_v1,
      {@initializing_farm_v1, farm_init}
    )
    {:noreply, socket}
  end

  def pub_farm_initialized_v1(payload, socket) do
    Logger.info("Farm Initialized: #{inspect(payload)}")
    {:ok, farm_init} = FarmInit.from_map(payload["farm_init"])
    Phoenix.PubSub.broadcast!(
      Swai.PubSub,
      @farm_initialized_v1,
      {@farm_initialized_v1, farm_init}
    )
    {:noreply, socket}
  end

  def pub_farm_detached_v1(payload, socket) do
    Logger.info("Farm Detached: #{inspect(payload)}")
    {:ok, farm_init} = FarmInit.from_map(payload["farm_init"])
    Phoenix.PubSub.broadcast!(
      Swai.PubSub,
      @farm_detached_v1,
      {@farm_detached_v1, farm_init}
    )
    {:noreply, socket}
  end



end
