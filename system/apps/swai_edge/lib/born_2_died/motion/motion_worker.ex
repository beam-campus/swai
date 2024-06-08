defmodule Born2Died.MotionWorker do
  use GenServer, restart: :transient

  @moduledoc """
  Born2Died.MotionWorker is a GenServer that manages the movements of a life
  """

  require Logger

  alias Born2Died.State, as: LifeState
  alias Born2Died.Movement, as: Movement
  alias Born2Died.MotionEmitter, as: MotionChannel
  alias Schema.Identity, as: Identity
  alias Born2Died.System, as: System

  import Euclid2D

  @scaling_factor 1



  ################ INTERFACE ############


  def move_forward(%LifeState{} = me, distance)
      when me.status == "idle" do
    heading = heading(me.prev_pos, me.pos)

    new_pos =
      calculate_endpoint(me.pos, heading, distance * @scaling_factor)

    movement = %Movement{
      born2died_id: me.id,
      to: new_pos,
      delta_t: 1,
      mng_farm_id: me.mng_farm_id,
      edge_id: me.edge_id,
      life: me.life,
      from: me.pos,
      heading: Euclid2D.heading(me.pos, new_pos)
    }

    move(movement)

    me
  end
  def move_away_from(%LifeState{} = me, %LifeState{} = other, distance)
      when me.id != other.id
      and
      me.status == "idle" do
    heading = away_heading(other.prev_pos, other.pos)

    new_pos =
      calculate_endpoint(me.pos, heading, distance * @scaling_factor)

    movement = %Movement{
      born2died_id: me.id,
      to: new_pos,
      delta_t: 1,
      mng_farm_id: me.mng_farm_id,
      edge_id: me.edge_id,
      life: me.life,
      from: me.pos,
      heading: Euclid2D.heading(me.pos, new_pos)
    }

    move(movement)

    me
  end

  def move_away_from(%LifeState{} = me, %LifeState{} = _other, _distance), do: me


  def move_towards(%LifeState{} = me, %LifeState{} = other, distance)
      when me.id != other.id
      and
      me.status == "idle" do
    heading = Euclid2D.heading(me.pos, other.pos)

    new_pos =
      calculate_endpoint(me.pos, heading, distance * @scaling_factor)

    movement = %Movement{
      born2died_id: me.id,
      to: new_pos,
      delta_t: 1,
      mng_farm_id: me.mng_farm_id,
      edge_id: me.edge_id,
      life: me.life,
      from: me.pos,
      heading: Euclid2D.heading(me.pos, new_pos)
    }

    move(movement)

    me
  end

  def move_towards(%LifeState{} = me, %LifeState{} = _other, _distance), do: me

  def move(%Movement{} = movement) do
    Process.sleep(100)

    GenServer.cast(
      via(movement.born2died_id),
      {:move, movement}
    )

  end

  ############### CALLBACKS #############

  @impl GenServer
  def init(%Identity{} = identity) do
    Logger.info("motion.worker: #{Colors.born2died_theme(self())}")
    {:ok, identity}
  end

  @impl GenServer
  def handle_cast({:move, %Movement{} = movement}, %Identity{} = identity) do

    this = System.get_state(identity.drone_id)

    this
    |> Map.put(:status, "moving")
    |> Map.put(:prev_pos, this.pos)
    |> Map.put(:pos, movement.to)

    System.save_state(identity.drone_id, this)

    MotionChannel.emit_life_moved(movement)

    this
    |> Map.put(:status, "idle")
    System.save_state(identity.drone_id, this)

    {:noreply, identity}
  end

  ######################### PLUMBING ###############################
  def via(id),
    do: Edge.Registry.via_tuple({:motion_worker, to_name(id)})

  def to_name(id),
    do: "drone.motion_worker.#{id}"

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
