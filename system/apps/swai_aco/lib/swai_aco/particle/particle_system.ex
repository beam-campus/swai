defmodule SwaiAco.Particle.System do
  @moduledoc """
  This module is responsible for managing the particles in the system.
  """
  use GenServer

  alias Particle.Init, as: ParticleInit
  alias Particle.Emitter, as: ParticleEmitter
  alias Swai.Registry, as: SwaiRegistry

  require Logger
  require Colors

  def start(particle_init) do
    case start_link(particle_init) do
      {:ok, pid} ->
        Logger.debug("Started [#{__MODULE__} > #{inspect(pid)}]]")
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.warning("Already Started [#{__MODULE__} > #{inspect(pid)}]]")
        {:ok, pid}

      {:error, reason} ->
        Logger.error("Failed to start #{__MODULE__}: #{reason}")
        {:error, reason}
    end
  end

  @impl true
  def init(%ParticleInit{particle_id: particle_id} = particle) do
    Process.flag(:trap_exit, true)

    sub_systems = []

    Supervisor.start_link(
      sub_systems,
      name: via_sup(particle_id),
      strategy: :one_for_one
    )

    Process.send_after(self(), :HEART_BEAT, 2_000)
    Logger.debug("Particle is up => #{Colors.particle_theme(self())}")
    ParticleEmitter.emit_particle_initialized(particle)

    {:ok, particle}
  end

  ### HEARTBEAT
  @impl true
  def handle_info(:HEART_BEAT, particle) do
    Process.send_after(self(), :HEART_BEAT, round(1_000))
    {:noreply, particle}
  end

  ### PLUMBING 
  def to_name(particle_id),
    do: "particle.system:#{particle_id}"

  def via(key),
    do: SwaiRegistry.via_tuple({__MODULE__, to_name(key)})

  def via_sup(key),
    do: SwaiRegistry.via_tuple({:particle_sup, to_name(key)})

  def child_spec(%ParticleInit{particle_id: part_id} = particle) do
    %{
      id: to_name(part_id),
      start: {__MODULE__, :start, [particle]},
      type: :supervisor,
      restart: :temporary
    }
  end

  def which_children(part_id) do
    Supervisor.which_children(via_sup(part_id))
  end

  def start_link(%ParticleInit{particle_id: part_id} = particle),
    do:
      GenServer.start_link(
        __MODULE__,
        particle,
        name: via(part_id)
      )
end
