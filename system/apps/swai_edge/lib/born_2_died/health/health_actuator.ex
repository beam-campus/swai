defmodule Born2Died.HealthActuator do
  @moduledoc """
  Born2Died.HealthActuator is the worker process that is spawned for each Life.
  """
  use GenServer
  require Logger

  alias Born2Died.HealthChannel, as: HealthChannel
  alias Born2Died.HealthRules, as: HealthRules
  alias Schema.Identity, as: Identity
  alias Born2Died.System, as: Drone
  alias Born2Died.State, as: LifeState

  ################ INTERFACE ###############
  def live(life_state_id),
    do:
      GenServer.cast(
        via(life_state_id),
        {:live}
      )

  def die(life_state_id),
    do:
      GenServer.cast(
        via(life_state_id),
        {:die}
      )

  def get_state(life_state_id),
    do:
      GenServer.call(
        via(life_state_id),
        {:get_state}
      )

  def heal(life_state_id, amount),
    do:
      GenServer.cast(
        via(life_state_id),
        {:heal, amount}
      )

  def hurt(life_state_id, amount),
    do:
      GenServer.cast(
        via(life_state_id),
        {:hurt, amount}
      )

  defp do_die(state) do
    new_state =
      %{state | status: "died"}

    HealthChannel.emit_life_died(new_state)

    Born2Died.System.stop(state.life.id)

    new_state
  end

  ################# CALLBACKS #####################
  @impl GenServer
  def init(%Identity{} = identity) do
    # Process.flag(:trap_exit, true)
    Logger.info("health.worker: #{Colors.born2died_theme(self())}")

    {:ok, identity}
  end

  # @impl GenServer
  # def terminate(reason, state) do
  #   {:stop, reason, state}
  # end

  # @impl GenServer
  # def handle_info({:EXIT, _from_id, reason}, state) do
  #   {:stop, reason, state}
  # end


  ################# HANDLE_CAST #####################
  @impl GenServer
  def handle_cast({:live}, state)
      when state.status == "died",
      do: {:noreply, state}

  @impl GenServer
  def handle_cast({:live}, %Identity{} = identity) do
    %LifeState{} = state = Drone.get_state(identity.drone_id)
    %LifeState{} = new_state = HealthRules.live(state)
    Drone.save_state(identity.drone_id, new_state)
    HealthChannel.emit_life_state_changed(new_state)
    {:noreply, identity}
  end

  @impl GenServer
  def handle_cast({:die}, state),
    do: {:noreply, do_die(state)}

  ################# PLUMBING #####################
  def to_name(id),
    do: "drone.health_worker.#{id}"

  def via(id),
    do: Edge.Registry.via_tuple({:health_worker, to_name(id)})

  def child_spec(%Identity{} = identity) do
    %{
      id: to_name(identity.drone_id),
      start: {__MODULE__, :start_link, [identity]},
      type: :worker,
      restart: :transient
    }
  end

  def start_link(%Identity{} = identity) do
    Logger.debug("health.worker: #{Colors.born2died_theme(self())}")
    GenServer.start_link(
      __MODULE__,
      identity,
      name: via(identity.drone_id)
    )
  end

end
