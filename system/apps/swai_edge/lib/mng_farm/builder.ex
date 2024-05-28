defmodule MngFarm.Builder do
  use GenServer

  @moduledoc """
  MngFarm.Builder is a GenServer that builds the herd of animals for a Farm.
  """

  # alias Field.Init, as: FieldInit
  # alias MngFarm.System, as: FarmSystem
  alias MngFarm.Init, as: FarmInit

  ################ INTERNALS ################

  ##### CALLBACKS #####
  @impl GenServer
  def init(%FarmInit{} = mng_farm_init) do
    Process.flag(:trap_exit, true)
    MngFarm.Server.populate_live_stock(mng_farm_init)

    # MngFarm.Server.generate_fields(mng_farm_init)
    # MngFarm.Server.initiate_nature(mng_farm_init)

    {:ok, mng_farm_init}
  end

  @impl GenServer
  def terminate(reason, state) do
    {:ok, reason, state}
  end

  ###### HANDLE_CAST
  # @impl GenServer
  # def handle_cast({:build_herd, mng_farm_init}, state) do
  #   Swai.MngFarm.Herd.populate(mng_farm_init)
  #   {:noreply, state}
  # end

  ###### HANDLE_INFO ###############
  @impl GenServer
  def handle_info({:EXIT, _from, reason}, state) do
    {:stop, reason, state}
  end

  ####### PLUMBING ########
  defp to_name(mng_farm_id),
    do: "mng_farm.builder.#{mng_farm_id}"

  def via(mng_farm_id),
    do: Edge.Registry.via_tuple({:mng_farm_herd_builder, to_name(mng_farm_id)})

  def child_spec(%FarmInit{} = mng_farm_init) do
    %{
      id: to_name(mng_farm_init.id),
      start: {__MODULE__, :start_link, [mng_farm_init]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(%FarmInit{} = mng_farm_init),
    do:
      GenServer.start_link(
        __MODULE__,
        mng_farm_init,
        name: via(mng_farm_init.id)
      )
end
