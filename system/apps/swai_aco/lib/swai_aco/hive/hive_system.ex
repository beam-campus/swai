defmodule Hive.System do
  @moduledoc """
  This module is responsible for managing the particles in the system.
  """
  use GenServer

  alias Swai.Registry, as: SwaiRegistry
  alias SwaiAco.Settings, as: Settings
  alias Hive.Init, as: HiveInit
  alias Hive.Emitter, as: HiveEmitter
  alias Schema.SwarmLicense, as: License

  require Logger
  require Colors

  @freq_hz Settings.model_frequency_hz() / 10

  ## Get the swarm of particles
  def get_particles(hive_id) do
    case which_children(hive_id) do
      {:ok, children} ->
        children

      {:error, reason} ->
        Logger.error("Failed to get particles: #{inspect(reason)}")
        []
    end
  end

  ## Count the number of particles
  def count_particles(hive_id) do
    Supervisor.count_children(via_sup(hive_id))
  end

  #################### START  ####################
  def start(hive_init) do
    case start_link(hive_init) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        {:ok, pid}

      {:error, reason} ->
        Logger.error("Failed to start hive.system: #{inspect(reason)}")
        {:error, reason}
    end
  end

  #################### INIT ####################
  @impl true
  def init(
        %HiveInit{
          scape_name: scape_name,
          hive_no: hive_no,
          hive_id: hive_id
        } = hive_init
      ) do
    Process.flag(:trap_exit, true)

    Supervisor.start_link(
      [],
      name: via_sup(hive_id),
      strategy: :one_for_one
    )

    Process.send_after(self(), :TICK, round(1_000 / @freq_hz))
    Logger.debug("hive[#{scape_name}][#{hive_no}] is up => #{Colors.particle_theme(self())}")

    HiveEmitter.emit_hive_initialized(hive_init)

    {:ok, hive_init}
  end

  ## SPAWN PARTICLES

  ## GET PARTICLES

  ################### TICK   ##############################
  @impl true
  def handle_info(:TICK, %HiveInit{license_id: nil} = state) do
    new_state =
      case HiveEmitter.try_reserve_license(state) do
        %License{license_id: license_id} = license ->
          new_state =
            %HiveInit{
              state
              | license_id: license_id,
                license: Map.from_struct(license)
            }

          HiveEmitter.emit_hive_occupied(new_state)
          new_state

        _ ->
          state
      end

    Process.send_after(self(), :TICK, round(1_000 / @freq_hz))
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:TICK, %HiveInit{hive_id: hive_id} = state) do
    new_state =
      if count_particles(hive_id) == 0 do
        HiveEmitter.emit_hive_vacated(state)
        %HiveInit{state | license_id: nil, license: nil}
      else
        state
      end

    Process.send_after(self(), :TICK, round(1_000 / @freq_hz))
    {:noreply, new_state}
  end

  ################### PLUMBING ###################
  def to_name(key),
    do: "hive.system:#{key}"

  def via(key),
    do: SwaiRegistry.via_tuple({:hive_sys, to_name(key)})

  def via_sup(key),
    do: SwaiRegistry.via_tuple({:hive_sup, to_name(key)})

  def child_spec(%{hive_id: hive_id} = hive_init) do
    %{
      id: to_name(hive_id),
      start: {__MODULE__, :start, [hive_init]},
      type: :supervisor,
      restart: :transient
    }
  end

  def which_children(hive_id) do
    Supervisor.which_children(via_sup(hive_id))
  end

  def start_link(%{hive_id: hive_id} = hive_init),
    do:
      GenServer.start_link(
        __MODULE__,
        hive_init,
        name: via(hive_id)
      )
end
