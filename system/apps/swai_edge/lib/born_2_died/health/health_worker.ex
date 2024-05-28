defmodule Born2Died.HealthWorker do
  @moduledoc """
  Born2Died.HealthWorker is the worker process that is spawned for each Life.
  """
  use GenServer
  require Logger

  alias Born2Died.HealthEmitter, as: LifeEmitter
  alias Born2Died.State, as: LifeState

  ################ INTERFACE ###############
  def live(life_init_id),
    do:
      GenServer.cast(
        via(life_init_id),
        {:live}
      )

  def die(life_init_id),
    do:
      GenServer.cast(
        via(life_init_id),
        {:die}
      )

  def get_state(life_init_id),
    do:
      GenServer.call(
        via(life_init_id),
        {:get_state}
      )

  def heal(life_init_id, amount),
    do:
      GenServer.cast(
        via(life_init_id),
        {:heal, amount}
      )

  def hurt(life_init_id, amount),
    do:
      GenServer.cast(
        via(life_init_id),
        {:hurt, amount}
      )

  ############################### INTERNALS #############################
  defp do_cron(state) do
    state =
      state
      |> do_process_health()

    live(state.id)
    state
  end

  defp do_process_health(state) when state.vitals.health <= 0 do
    die(state.life.id)
    state
  end

  defp do_process_health(state),
    do: state

  defp do_die(state) do
    new_state =
      state
      |> Map.put(:status, "died")

    LifeEmitter.emit_life_died(new_state)

    Born2Died.System.stop(state.life.id)

    new_state
  end

  ################# CALLBACKS #####################
  @impl GenServer
  def init(state) do
    Logger.info("health.worker: #{Colors.born2died_theme(self())}")

    Process.flag(:trap_exit, true)
    LifeEmitter.emit_initializing_life(state)


    Cronlike.start_link(%{
      interval: :rand.uniform(10),
      unit: :second,
      callback_function: &do_cron/1,
      caller_state: state
    })

    LifeEmitter.emit_life_initialized(state)
    {:ok, state}
  end

  @impl GenServer
  def terminate(reason, state) do
    {:stop, reason, state}
  end

  @impl GenServer
  def handle_info({:EXIT, _from_id, reason}, state) do
    {:stop, reason, state}
  end

  @impl GenServer
  def handle_call({:get_state}, _from, state) do
    Logger.debug(" \n\tGETTING STATE: #{state.life.name}  ")
    {:reply, state, state}
  end

  ################# HANDLE_CAST #####################
  @impl GenServer
  def handle_cast({:live}, state) when state.status == "died" do
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:live}, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:die}, state),
    do: {:noreply, do_die(state)}


  ################# PLUMBING #####################
  def to_name(life_init_id),
    do: "born2died.health_worker.#{life_init_id}"

  def via(life_init_id),
    do: Edge.Registry.via_tuple({:health_worker, to_name(life_init_id)})

  def child_spec(%LifeState{} = life_init) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [life_init]},
      type: :worker,
      restart: :transient
    }
  end

  def start_link(%LifeState{} = life_init),
    do:
      GenServer.start_link(
        __MODULE__,
        life_init,
        name: via(life_init.id)
      )

end
