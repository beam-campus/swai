defmodule Born2Died.AiWorker do
  use GenServer, restart: :transient

  @moduledoc """
  Born2Died.AiWorker is a GenServer that manages the AI of a life
  """

  require Logger

  alias Born2Died.MotionActuator, as: MotionActuator
  alias Born2Died.State, as: LifeState
  alias Born2Died.Movement, as: Movement
  alias Born2Died.System, as: System
  alias Schema.Identity, as: Identity

  alias Euclid2D

  alias Schema.Identity

  @normal_speed 1
  @action_radius 5
  @vision_radius 300

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
    |> MotionActuator.move_away_from(new_life, :rand.uniform(@normal_speed))
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
    this = %{this | status: "born"}
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
      %{this | status: "moving", prev_pos: this.pos, pos: movement.to}

    System.save_state(identity.drone_id, new_state)
    {:noreply, identity}
  end

  @impl GenServer
  def handle_cast({:process_movement, %Movement{} = movement}, %Identity{} = identity)
      when movement.mng_farm_id == identity.farm_id do
    %LifeState{} = this = System.get_state(identity.drone_id)
    %LifeState{} = that = System.get_state(movement.born2died_id)

    case calculate_motion(this, that) do
      {:away_from, speed} ->
        this
        |> MotionActuator.move_away_from(that, speed)

      {:towards, speed} ->
        this
        |> MotionActuator.move_towards(that, speed)

      {:forward, speed} ->
        this
        |> MotionActuator.move_forward(speed)
    end

    # cond do
    #   Euclid2D.in_radius?(this.pos, movement.to, @action_radius) ->
    #     identity
    #     |> perform_action(that)

    #   Euclid2D.in_radius?(this.pos, movement.to, @vision_radius) ->
    #     case calculate_motion(this, that) do
    #       {:away_from, speed} ->
    #         this
    #         |> MotionActuator.move_away_from(that, speed)

    #       {:towards, speed} ->
    #         this
    #         |> MotionActuator.move_towards(that, speed)

    #       {:forward, speed} ->
    #         this
    #         |> MotionActuator.move_forward(speed)
    #     end
    # end

    {:noreply, identity}
  end

  @impl GenServer
  def handle_cast({:process_movement, %Movement{} = _movement}, identity),
    do: {:noreply, identity}

  ########################## perform_action ############################

  @impl GenServer
  def handle_cast({:perform_action, %LifeState{} = _that}, identity) do
    %LifeState{} = this = System.get_state(identity.drone_id)

    # TODO: implement action
    new_state =
      %{this | status: "performing_action"}

    System.save_state(identity.drone_id, new_state)
    {:noreply, identity}
  end

  defp calculate_motion(%LifeState{} = this, %LifeState{} = that) do
    cond do
      could_breed?(this, that) or could_fight?(this, that) ->
        {:towards, @normal_speed}

      could_fear?(this, that) ->
        {:away_from, @normal_speed}

      true ->
        {:forward, @normal_speed}
    end
  end

  defp could_fear?(%LifeState{} = this, %LifeState{} = that),
    do:
      this.vitals.health < 20 or that.vitals.health < 20 or
        this.vitals.energy <= 50 or that.vitals.energy <= 50 or
        this.vitals.age >= 30 or that.vitals.age >= 30 or
        this.vitals.is_pregnant or that.vitals.is_pregnant

  defp could_fight?(%LifeState{} = this, %LifeState{} = that),
    do:
      this.life.gender == "male" and that.life.gender == "male" and
        this.vitals.health > 50 and that.vitals.health > 50 and
        this.vitals.energy > 50 and that.vitals.energy > 50 and
        this.vitals.age > 5 and that.vitals.age > 5 and
        this.vitals.age < 20 and that.vitals.age < 20

  defp could_breed?(%LifeState{} = this, %LifeState{} = that),
    do:
      this.life.gender != that.life.gender and
        this.vitals.health > 50 and that.vitals.health > 50 and
        this.vitals.energy > 50 and that.vitals.energy > 50 and
        this.vitals.age > 5 and that.vitals.age > 5 and
        this.vitals.age < 20 and that.vitals.age < 20 and
        not this.vitals.is_pregnant and not that.vitals.is_pregnant

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
