defmodule SwaiAco.Arena.System do
  @moduledoc """
  This module is responsible for managing the particles in the system.
  """
  use GenServer

  alias Particle.Init, as: ParticleInit
  alias Swai.Registry, as: SwaiRegistry
  alias SwaiAco.Settings, as: Settings
  alias Arena.Init, as: ArenaInit
  alias Hive.Init, as: HiveInit

  require Logger
  require Colors

  @freq_hz Settings.model_frequency_hz()

  ####################### START #######################
  def start(%ArenaInit{} = arena_init) do
    case start_link(arena_init) do
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

  ####################### INIT #######################
  @impl true
  def init(%ArenaInit{scape_id: scape_id} = arena_init) do
    Process.flag(:trap_exit, true)

    GenServer.cast(
      via(scape_id),
      {:build_arena, arena_init}
    )

    Process.send_after(self(), :TICK, round(1_000 / @freq_hz))
    Logger.debug(
      "#{__MODULE__} is up: #{Colors.arena_theme(self())} scape_id: #{arena_init.scape_id}"
    )
    {:ok, arena_init}
  end

  ####################### BUILD ARENA #######################
  @impl true
  def handle_cast({:build_arena, %ArenaInit{scape_id: scape_id, nbr_of_hives: nbr_of_hives} = arena_init}, state) do
    Logger.debug("Building Arena for Scape [#{scape_id}]...")
    case Supervisor.start_link(
           [],
           strategy: :one_for_one,
           name: via_sup(scape_id)
         ) do
      {:ok, _} ->
        [1..nbr_of_hives]
        |> HiveInit.from_arena_init(arena_init)
        |> Enum.map(&start_hive/1)
        Logger.debug("Arena for Scape [#{scape_id}] ready!")

      {:error, reason} ->
        Logger.error("Failed to start #{__MODULE__}: #{reason}")
    end
    {:noreply, state}
  end

  ####################### START HIVE #######################
  defp start_hive(%HiveInit{} = hive_init) do

  end



  ####################### HEARTBEAT #######################
  @impl true
  def handle_info(:TICK, state) do
    Logger.debug("TICK: #{inspect(self())}")

    Process.send_after(self(), :TICK, round(1_000 / @freq_hz))
    {:noreply, state}
  end

  ####################### UNHANDLED INFO #######################
  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end



  ################### PLUMBING ###################
  def to_name(key),
    do: "#{__MODULE__}.#{key}"

  def via(key),
    do: SwaiRegistry.via_tuple({__MODULE__, to_name(key)})

  def via_sup(key),
    do: SwaiRegistry.via_tuple({:arena_sup, to_name(key)})

  def child_spec(%ArenaInit{scape_id: scape_id} = arena_init) do
    %{
      id: to_name(scape_id),
      start: {__MODULE__, :start, [arena_init]},
      type: :supervisor,
      restart: :transient
    }
  end

  def which_children(scape_id) do
    Supervisor.which_children(via_sup(scape_id))
  end

  def start_link(%ArenaInit{scape_id: scape_id} = arena_init),
    do:
      GenServer.start_link(
        __MODULE__,
        arena_init,
        name: via(scape_id)
      )
end
