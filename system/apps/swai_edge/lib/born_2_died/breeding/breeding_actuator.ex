defmodule Born2Died.BreedingActuator do
  use GenServer, restart: :transient

  @moduledoc """
  Born2Died.BreedingActuator is a GenServer that manages the mating of a life
  """

  require Logger

  alias Schema.Identity, as: Identity
  alias Born2Died.State, as: LifeState
  alias Born2Died.MatingEmitter, as: MatingChannel

  ################# INTERFACE ##############
  def impregnate(%Identity{} = me, %Identity{} = her),
    do:
      GenServer.cast(
        via(me.drone_id),
        {:impregnate, her}
      )

  ############# INIT #############
  @impl GenServer
  def init(%Identity{} = me) do
    Logger.info("mating.worker: #{Colors.born2died_theme(self())}")
    {:ok, me}
  end

  ########### IMPREGNATE ############

  @impl GenServer
  def handle_cast({:impregnate, %Identity{} = her_id}, %Identity{} = my_id) do
    her = System.get_state(her_id.drone_id)
    him = System.get_state(my_id.drone_id)

    her =
      %{her | status: "mating"}


    him =
      %{him | status: "mating"}

    {:noreply, my_id}
  end

  ############### handle unknown messages ######
  @impl GenServer
  def handle_cast(unknown, %Identity{} = me) do
    # Logger.alert("mating.worker #{inspect(self())}      \t unknown message = #{inspect(unknown)}")
    {:noreply, me}
  end

  ########### PLUMBING ############################

  def via(id),
    do: Edge.Registry.via_tuple({:mating_worker, to_name(id)})

  def to_name(id),
    do: "mating.actuator.#{id}"

  def child_spec(%Identity{} = me),
    do: %{
      id: to_name(me.drone_id),
      start: {__MODULE__, :start_link, [me]},
      type: :worker,
      restart: :transient
    }

  def start_link(%Identity{} = me),
    do:
      GenServer.start_link(
        __MODULE__,
        me,
        name: via(me.id)
      )
end
