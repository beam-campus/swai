defmodule Born2Died.MotionWorker do
  use GenServer, restart: :transient

  @moduledoc """
  Born2Died.MotionWorker is a GenServer that manages the movements of a life
  """

  require Logger

  alias Born2Died.Movement
  alias Born2Died.MotionState, as: MotionState
  alias Born2Died.Movement, as: Movement
  alias Born2Died.System, as: LifeSystem

  ################ INTERFACE ############

  def move(life_init_id),
    do:
      GenServer.cast(
        via(life_init_id),
        {:move}
      )

  ############### INTERNALS #############

  # defp try_move(%{state: life_init, movement: movement}),
  #   do: move(life_init.id, movement)

  ############### CALLBACKS #############

  @impl GenServer
  def init(%MotionState{} = state) do
    Logger.info("motion.worker: #{Colors.born2died_theme(self())}")

    Cronlike.start_link(%{
      interval: :rand.uniform(3),
      unit: :second,
      callback_function: &move/1,
      caller_state: state.born2died_id
      # caller_state: %{state: state, movement: Movement.random(state)}
    })

    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:move}, %MotionState{} = state) do
    movement =
      state
      |> Movement.random()

    new_state =
    state
    |> Map.put(:pos, movement.to)

    LifeSystem.register_movement(state.born2died_id, movement)

    {:noreply, new_state}
  end

  ########### PLUMBING ###########

  def via(life_init_id),
    do: Edge.Registry.via_tuple({:motion_worker, to_name(life_init_id)})

  def to_name(life_init_id),
    do: "life.motion_worker.#{life_init_id}"

  def child_spec(%MotionState{} = init),
    do: %{
      id: to_name(init.born2died_id),
      start: {__MODULE__, :start_link, [init]},
      type: :worker,
      restart: :transient
    }

  def start_link(%MotionState{} = state),
    do:
      GenServer.start_link(
        __MODULE__,
        state,
        name: via(state.born2died_id)
      )
end
