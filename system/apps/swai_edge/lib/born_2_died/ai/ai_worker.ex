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

  ############# API ############
  alias Schema.Identity

  def register_birth(%Identity{} = identity, %LifeState{} = life),
    do:
      GenServer.cast(
        via(identity.drone_id),
        {:register_birth, life}
      )

  def register_movement(%Identity{} = identity, %Movement{} = movement),
    do:
      GenServer.cast(
        via(identity.drone_id),
        {:register_movement, movement}
      )

  defp on_new_life(%LifeState{} = drone, %LifeState{} = new_life) do
    Logger.info("ai.worker[#{inspect(self())}] => #{new_life.id} is born")
    drone
    |> MotionWorker.move_away_from(new_life)
  end

  ####################### CALLBACKS #######################
  @impl GenServer
  def init(%Identity{} = identity) do
    Logger.info("ai.worker: #{Colors.born2died_theme(self())}")
    {:ok, identity}
  end

  ####################### handle_cast #######################
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
  def handle_cast({:register_birth, %LifeState{} = _life}, identity),
    do: {:noreply, identity}

  @impl GenServer
  def handle_cast({:register_movement, %Movement{} = movement}, identity)
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
  def handle_cast({:register_movement, %Movement{} = movement}, identity) do
    %LifeState{} = this = System.get_state(identity.drone_id)
    %LifeState{} = that = System.get_state(movement.born2died_id)

    new_state =
      cond do
      that.life.gender == this.life.gender ->
        this
        |> MotionWorker.move_towards(that)
      that.life.gender != this.life.gender ->
        this
        |> MotionWorker.move_towards(that)
        true ->
          this
    end

    System.save_state(identity.drone_id, new_state)
    {:noreply, identity}
  end


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
