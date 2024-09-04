defmodule Hive.System do
  @moduledoc """
  This module is responsible for managing the particles in the system.
  """
  use GenServer

  alias Swai.Registry, as: SwaiRegistry
  alias SwaiAco.Settings, as: Settings
  alias Hive.Init, as: HiveInit
  alias Hive.Emitter, as: HiveEmitter

  require Logger
  require Colors

  @freq_hz Settings.model_frequency_hz()

  #################### START  ####################
  def start(hive_init) do
    case start_link(hive_init) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        {:ok, pid}

      {:error, reason} ->
        Logger.error("Failed to start #{__MODULE__}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  #################### INIT ####################
  @impl true
  def init(%HiveInit{scape_name: scape_name, hive_no: hive_no} = hive_init) do
    Process.flag(:trap_exit, true)

    Process.send_after(self(), :tick, round(1_000 / @freq_hz))
    Logger.debug("hive[#{scape_name}][#{hive_no}] is up => #{Colors.particle_theme(self())}")

    HiveEmitter.emit_hive_initialized(hive_init)

    {:ok, hive_init}
  end

  ################### TICK   ##############################
  @impl true
  def handle_info(:tick, %HiveInit{} = state) do
    Process.send_after(self(), :tick, round(1_000 / @freq_hz))
    {:noreply, state}
  end

  ################### PLUMBING ###################
  def to_name(key),
    do: "hive.system.#{key}"

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
