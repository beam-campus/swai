defmodule Born2Died.AiWorker do
  use GenServer, restart: :transient

  @moduledoc """
  Born2Died.AiWorker is a GenServer that manages the AI of a life
  """

  require Logger

  alias Born2Died.MotionWorker, as: MotionWorker
  alias Born2Died.State, as: LifeState
  alias Born2Died.Movement, as: Movement
  alias Born2Died.System, as: System
  alias Schema.Identity, as: Identity

  alias Euclid2D

  alias Schema.Identity

  @normal_speed 2

  ############# API ############

  def register_birth(%Identity{} = identity, %LifeState{} = life),
    do:
      GenServer.cast(
        via(identity.drone_id),
        {:register_birth, life}
      )

  def process_movement(%Identity{} = identity, %Movement{} = movement),
    do:
      GenServer.cast(
        via(identity.drone_id),
        {:process_movement, movement}
      )

  def perform_action(%Identity{} = identity, %Movement{} = movement),
    do:
      GenServer.cast(
        via(identity.drone_id),
        {:perform_action, movement}
      )

  defp on_new_life(%LifeState{} = drone, %LifeState{} = new_life) do
    drone
    |> MotionWorker.move_away_from(new_life, :rand.uniform(3))
  end

  ####################### CALLBACKS #######################
  @impl GenServer
  def init(%Identity{} = identity) do
    Logger.info("ai.worker: #{Colors.born2died_theme(self())}")
    {:ok, identity}
  end

  ####################### register_birth  #######################
  @impl GenServer
  def handle_cast({:register_birth, %LifeState{} = life}, identity)
      when life.id == identity.drone_id do
    this = System.get_state(identity.drone_id)
    this |> Map.put(:status, "born")
    System.save_state(identity.drone_id, this)
    {:noreply, identity}
  end

  @impl GenServer
  def handle_cast({:register_birth, %LifeState{} = life}, %Identity{} = identity)
      when life.mng_farm_id == identity.farm_id do
    this = System.get_state(identity.drone_id)

    new_state =
      this
      |> on_new_life(life)

    System.save_state(identity.drone_id, new_state)

    {:noreply, identity}
  end

  @impl GenServer
  def handle_cast({:register_birth, %LifeState{} = _life}, identity), do: {:noreply, identity}

  ########################## process_movement ############################
  @impl GenServer
  def handle_cast({:process_movement, %Movement{} = movement}, identity)
      when movement.born2died_id == identity.drone_id do
    this = System.get_state(identity.drone_id)

    new_state =
      this
      |> Map.put(:prev_pos, this.pos)
      |> Map.put(:pos, movement.to)
      |> Map.put(:status, "moving")

    System.save_state(identity.drone_id, new_state)
    {:noreply, identity}
  end

  @impl GenServer
  def handle_cast({:process_movement, %Movement{} = movement}, identity), do: {:noreply, identity}

  ########################## perform_action ############################

  @impl GenServer
  def handle_cast({:perform_action, %Movement{} = movement}, identity) do
    %LifeState{} = this = System.get_state(identity.drone_id)
    %LifeState{} = _that = System.get_state(movement.born2died_id)

    new_state =
      this
      |> Map.put(:status, "performing_action")

    System.save_state(identity.drone_id, new_state)
    {:noreply, identity}
  end

  defp same_gender?(%LifeState{} = this, %LifeState{} = that),
    do: that.life.gender == this.life.gender

  ################# PLUMBING #################
  def via(id),
    do: Edge.Registry.via_tuple({:ai_worker, to_name(id)})

  def to_name(id),
    do: "drone.ai_worker.#{id}"

  def child_spec(%Identity{} = identity),
    do: %{
      id: to_name(identity.drone_id),
      start: {__MODULE__, :start_link, [identity]},
      type: :worker,
      restart: :transient
    }

  def start_link(%Identity{} = identity),
    do:
      GenServer.start_link(
        __MODULE__,
        identity,
        name: via(identity.drone_id)
      )
end
