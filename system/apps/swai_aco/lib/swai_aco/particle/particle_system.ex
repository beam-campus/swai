defmodule SwaiAco.Particle.System do
  @moduledoc """
  This module is responsible for managing the particles in the system.
  """
  use GenServer

  alias Particle.Init, as: ParticleInit
  alias Particle.Emitter, as: ParticleEmitter
  alias Swai.Registry, as: SwaiRegistry
  alias Swai.Defaults, as: Limits
  alias Phoenix.PubSub, as: PubSub
  alias Particle.Facts, as: ParticleFacts

  require Logger
  require Colors

  @particle_facts ParticleFacts.particle_facts()
  @particle_moved_v1 ParticleFacts.particle_moved_v1()
  @heart_beat Limits.particle_heartbeat()

  ################### INTERNALS ##################

  defp do_live(_),
    do: Process.send_after(self(), :HEART_BEAT, @heart_beat)

  defp do_kill!(%ParticleInit{particle_id: particle_id} = particle) do
    Logger.alert("[#{particle_id}] DIED!")

    ParticleEmitter.emit_particle_died(particle)

    SwaiRegistry.unregister(via(particle_id))
    SwaiRegistry.unregister(via_sup(particle_id))

    {:stop, :normal, particle}
  end

  defp do_age(%ParticleInit{particle_id: particle_id, age: age, ticks: ticks} = particle) do
    new_age =
      if rem(age, Limits.particle_heartbeats_per_age()) == 0 do
        Logger.info("[#{particle_id}] is AGEING: #{age}, ticks: #{ticks}")
        age + 1
      else
        age
      end

    Process.send_after(self(), :HEART_BEAT, round(@heart_beat))

    %ParticleInit{
      particle
      | age: new_age,
        ticks: ticks + 1
    }
  end

  defp must_die?(%ParticleInit{age: age, health: health, energy: energy}),
    do: age >= Limits.particle_max_age() or health <= 0 or energy <= 0

  ###################### API ######################
  def get_particle(particle_id),
    do:
      GenServer.call(
        via(particle_id),
        :get_particle
      )

  def start(particle_init) do
    case start_link(particle_init) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        {:ok, pid}

      {:error, reason} ->
        Logger.error("Failed to start #{__MODULE__}: #{inspect(reason, pretty: true)}")
        {:error, reason}
    end
  end

  ###################### INIT ######################
  @impl true
  def init(%ParticleInit{particle_id: particle_id, hive_id: hive_id} = particle) do
    Process.flag(:trap_exit, true)

    sub_systems = [
      {SwaiAco.Particle.MoveActuator, particle},
      {SwaiAco.Particle.AIWorker, %{id: particle_id}}
    ]

    case Supervisor.start_link(
           sub_systems,
           name: via_sup(particle_id),
           strategy: :one_for_one
         ) do
      {:ok, _} ->
        :edge_pubsub
        |> PubSub.subscribe(@particle_facts)

        Logger.alert("SPAWNED: Particle [#{particle_id}] in Hive [#{hive_id}]")
        do_live(2_000)
        Logger.debug("#{__MODULE__} is up => #{Colors.particle_theme(self())}")
        ParticleEmitter.emit_particle_spawned(particle)
        {:ok, particle}

      {:error, reason} ->
        Logger.error(
          "Failed to start Particle subsystems for Particle :[#{particle_id}]:Reason: #{inspect(reason, pretty: true)}"
        )

        {:stop, reason}
    end
  end

  ######################## HEARTBEAT ######################
  @impl true
  def handle_info(:HEART_BEAT, particle) do
    new_particle =
      if must_die?(particle) do
        particle
        |> do_kill!()
      else
        do_live(1_000)

        particle
        |> do_age()
      end

    {:noreply, new_particle}
  end

  ################ MOVED ######################
  @impl true
  def handle_info({@particle_moved_v1, movememt}, particle) do
    new_particle =
      case ParticleInit.from_map(particle, movememt) do
        {:ok, new_particle} ->
          new_particle

        {:error, changeset} ->
          Logger.error("Invalid movment: #{inspect(changeset, pretty: true)}")
          particle
      end

    ParticleEmitter.emit_particle_changed(new_particle)
    {:noreply, new_particle}
  end

  ###################### GET PARTICLE ##################
  @impl true
  def handle_call(:get_particle, _from, particle),
    do: {:reply, particle, particle}

  ###################### PLUMBING ######################
  def to_name(particle_id),
    do: "particle.system:#{particle_id}"

  def via(key),
    do: SwaiRegistry.via_tuple({__MODULE__, to_name(key)})

  def via_sup(key),
    do: SwaiRegistry.via_tuple({:particle_sup, to_name(key)})

  def child_spec(%ParticleInit{particle_id: part_id} = particle),
    do: %{
      id: to_name(part_id),
      start: {__MODULE__, :start, [particle]},
      type: :supervisor,
      restart: :temporary
    }

  def which_children(part_id),
    do: Supervisor.which_children(via_sup(part_id))

  def start_link(%ParticleInit{particle_id: part_id} = particle),
    do:
      GenServer.start_link(
        __MODULE__,
        particle,
        name: via(part_id)
      )
end
