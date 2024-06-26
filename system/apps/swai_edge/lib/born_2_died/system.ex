defmodule Born2Died.System do
  use GenServer

  @moduledoc """
  The Life System is a GenServer that manages the
  Life Worker and Life Channel
  """

  require Logger

  alias Born2Died.HealthActuator
  alias Schema.Identity, as: Identity
  alias Born2Died.State, as: LifeState
  alias Born2Died.HealthChannel, as: HealthChannel

  def do_birth(life_id, delta_x, delta_y),
    do:
      GenServer.cast(
        via(life_id),
        {:do_birth, life_id, delta_x, delta_y}
      )

  def stop(life_id) do
    try do
      Supervisor.stop(via_sup(life_id), :shutdown)
    rescue
      _ -> :ok
    end
  end

  def get_state(life_id),
    do:
      GenServer.call(
        via(life_id),
        {:get_state}
      )

  def save_state(life_id, state),
    do:
      GenServer.cast(
        via(life_id),
        {:save_state, state}
      )

  ########################## CALLBACKS ####################################
  @impl GenServer
  def init(%LifeState{} = state) do
    # Process.flag(:trap_exit, true)
    Logger.debug("drone.system: #{Colors.born2died_theme(self())}")

    identity = %Identity{
      edge_id: state.edge_id,
      scape_id: state.scape_id,
      region_id: state.region_id,
      farm_id: state.mng_farm_id,
      drone_id: state.id
    }

    children =
      [
        {Born2Died.AiWorker, identity},
        {Born2Died.MotionActuator, identity},
        {Born2Died.HealthActuator, identity},
        # {Born2Died.BreedingActuator, identity},
        {Born2Died.VisionSensor, identity}
        # {Born2Died.MilkingWorker, state},
        # {Born2Died.CombatWorker, state},

      ]

    Supervisor.start_link(
      children,
      name: via_sup(state.id),
      strategy: :one_for_one
    )

    Process.send_after(self(), :live, 1000)

    HealthChannel.emit_life_initialized(state)

    {:ok, state}
  end

  ############### CALLBACKS ############################
  @impl GenServer
  def terminate(_reason, _state) do
    :ok
  end

  ############### save_state ############################
  @impl GenServer
  def handle_cast({:save_state, state}, _state),
    do: {:noreply, state}

    ################## live ############################
  @impl GenServer
  def handle_cast({:live}, %LifeState{} = state) do
    HealthActuator.live(state.id)
    {:noreply, state}
  end

  ############### handle_call ############################
  @impl GenServer
  def handle_call({:get_state}, _from, state),
    do: {:reply, state, state}

  ################ handle_info #################
  @impl GenServer
  def handle_info({:EXIT, _from_id, reason}, state) do
    # Born2Died.HealthActuator.die(state.life.id)
    {:stop, reason, state}
  end

  @impl GenServer
  def handle_info(:live, %LifeState{} = state) do
    GenServer.cast(via(state.id), {:live})
    Process.send_after(self(), :live, 1000)
    {:noreply, state}
  end

  ######### INTERNALS ###################
  defp to_name(life_id),
    do: "life.system.#{life_id}"

  ############# PLUMBING ##################
  def via(life_id),
    do: Edge.Registry.via_tuple({:life_sys, to_name(life_id)})

  def via_sup(life_id),
    do: Edge.Registry.via_tuple({:life_sup, to_name(life_id)})

  def via_pubsub(life_id),
    do: Edge.Registry.via_tuple({:life_pubsub, to_name(life_id)})

  def via_agent(life_id),
    do: Edge.Registry.via_tuple({:life_agent, to_name(life_id)})

  def child_spec(%LifeState{} = state) do
    %{
      id: to_name(state.id),
      start: {__MODULE__, :start_link, [state]},
      type: :supervisor,
      restart: :transient
    }
  end

  def start_link(%LifeState{} = state),
    do:
      GenServer.start_link(
        __MODULE__,
        state,
        name: via(state.id)
      )
end
