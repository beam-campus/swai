defmodule MngFarm.Server do
  use GenServer

  alias Schema.Life
  require DynamicSupervisor
  require Logger

  # alias Field.Init, as: FieldInit
  alias Born2Died.System, as: LifeSystem
  alias Born2Died.State, as: LifeState

  alias MngFarm.Init, as: MngFarmInit


  @moduledoc """
  The Logatron.Far.Herd.System supervises the Lives in a Herd.
  """

  ################# API ##################

  # def initiate_nature(%MngFarmInit{} = mng_farm_init) do
  #   Enum.to_list(1..mng_farm_init.farm.nbr_of_fields)
  #   |> Enum.map(&NatureInit.from_mng_farm(&1, mng_farm_init))

  # end


  def populate_live_stock(%MngFarmInit{} = mng_farm_init) do
    Enum.to_list(1..mng_farm_init.farm.nbr_of_lives)
    |> Enum.map(&do_new_life/1)
    |> Enum.each(&do_start_born2died(&1, mng_farm_init))
  end

  # def generate_fields(%MngFarmInit{} = mng_farm_init) do
  #   Enum.to_list(1..mng_farm_init.max_depth)
  #   |> Enum.map(&FieldInit.from_mng_farm(&1, mng_farm_init))
  #   |> Enum.each(&start_field/1)
  # end

  # def start_field(%FieldInit{} = field_init),
  #   do:
  #     DynamicSupervisor.start_child(
  #       via_sup(field_init.mng_farm_id),
  #     {Field.System, field_init}
  #     )

  def birth_calves(mother_state, nbr_of_calves),
    do:
      GenServer.cast(
        via(mother_state.farm_id),
        {:birth_calves, mother_state, nbr_of_calves}
      )

  def which_children(mng_farm_id) do
    DynamicSupervisor.which_children(via_sup(mng_farm_id))
  end

  ################# CALLBACKS ##################

  @impl GenServer
  def handle_cast({:birth_calves, _mother, number}, state) do
    Enum.to_list(1..number)
    |> Enum.map(&do_new_life/1)
    |> Enum.each(& do_start_born2died(&1, state))

    {:noreply, state}
  end

  @impl GenServer
  def init(%MngFarmInit{} = mng_farm_init) do
    DynamicSupervisor.start_link(
      name: via_sup(mng_farm_init.id),
      strategy: :one_for_one
    )

    {:ok, mng_farm_init}
  end

  ############### INTERNALS ################
  defp do_new_life(_),
    do: Life.random()

  defp do_start_born2died(%Life{} = life, %MngFarmInit{} = mng_farm_init) do
    DynamicSupervisor.start_child(
      via_sup(mng_farm_init.id),
      {
        LifeSystem, LifeState.from_life(life, mng_farm_init)
      }
    )
  end

  ################# PLUMBING ##################
  def start_link(%MngFarmInit{} = mng_farm_init),
    do:
      GenServer.start_link(
        __MODULE__,
        mng_farm_init,
        name: via(mng_farm_init.id)
      )

  def child_spec(%MngFarmInit{} = mng_farm_init) do
    %{
      id: to_name(mng_farm_init.id),
      start: {__MODULE__, :start_link, [mng_farm_init]},
      type: :supervisor,
      restart: :permanent,
      shutdown: 500
    }
  end

  def to_name(mng_farm_id),
    do: "mng_farm.server.#{mng_farm_id}"

  def via(mng_farm_id),
    do: Edge.Registry.via_tuple({:mng_farm_herd, to_name(mng_farm_id)})

  def via_sup(mng_farm_id),
    do: Edge.Registry.via_tuple({:mng_farm_herd_sup, to_name(mng_farm_id)})
end
