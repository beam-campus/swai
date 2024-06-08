defmodule Born2Died.VisionWorker do
  use GenServer, restart: :transient

  @moduledoc """
  Born2Died.VisionWorker is a GenServer that manages the vision of a life
  """

  require Logger

  alias Phoenix.PubSub, as: Exchange

  alias Born2Died.State, as: LifeState
  alias Born2Died.Facts, as: Facts
  alias Born2Died.Movement, as: Movement
  alias Born2Died.AiWorker, as: AiWorker
  alias Schema.Identity, as: Identity
  alias Born2Died.System, as: System


  @vision_radius 10
  @action_radius 2


  @life_moved_v1 Facts.life_moved_v1()
  @life_initialized_v1 Facts.life_initialized_v1()

  ############# CALLBACKS #############

  @impl GenServer
  def init(%Identity{} = identity) do
    Logger.info("vision.worker: #{Colors.born2died_theme(self())}")
    Exchange.subscribe(Edge.PubSub, @life_moved_v1)
    Exchange.subscribe(Edge.PubSub, @life_initialized_v1)
    {:ok, identity}
  end

  ############## HANDLE_INFO ############
  @impl GenServer
  def handle_info(
        {@life_moved_v1, %Movement{born2died_id: drone_id} = _movement},
        %Identity{} = this
      )
      when drone_id == this.drone_id do
    {:noreply, this}
  end

  @impl GenServer
  def handle_info(
        {@life_moved_v1, %Movement{mng_farm_id: mng_farm_id} = movement},
        %Identity{} = identity
      )
      when mng_farm_id == identity.farm_id do
    this = System.get_state(identity.drone_id)

    cond do
      Euclid2D.in_radius?(this.pos, movement.to, @action_radius) ->
        identity
        |> AiWorker.perform_action(movement)

      Euclid2D.in_radius?(this.pos, movement.to, @vision_radius) ->
        identity
        |> AiWorker.process_movement(movement)

      true ->
        true
    end

    {:noreply, identity}
  end

  @impl GenServer
  def handle_info(
        {@life_initialized_v1, %LifeState{} = life},
        %Identity{} = this
      )
      when life.id != this.drone_id do
    this
    |> AiWorker.register_birth(life)

    {:noreply, this}
  end

  @impl GenServer
  def handle_info(_msg, identity), do: {:noreply, identity}

  ############# PLUMBING ############
  def via(id),
    do: Edge.Registry.via_tuple({:vision_worker, to_name(id)})

  def to_name(id),
    do: "drone.vision_worker.#{id}"

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
