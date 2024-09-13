defmodule Hive.System do
  @moduledoc """
  This module is responsible for managing the particles in the system.
  """
  use GenServer

  alias Hive.Emitter, as: HiveEmitter
  alias Hive.Init, as: HiveInit
  alias Hive.Status, as: HiveStatus
  alias Swai.Registry, as: SwaiRegistry

  require Logger
  require Colors

  @hive_status_vacant HiveStatus.hive_vacant()
  @hive_status_occupied HiveStatus.hive_occupied()

  ## Get the swarm of particles
  def get_particles(hive_id) do
    which_children(hive_id)
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

    Logger.debug("hive[#{scape_name}][#{hive_no}] is up => #{Colors.particle_theme(self())}")

    HiveEmitter.emit_hive_initialized(hive_init)

    Process.send_after(self(), :CLAIM_LICENSE, 30_000)

    {:ok, hive_init}
  end

  #################### HANDLE CAST ####################
  ## Handle Cast Fallthrough
  @impl true
  def handle_cast(_, state) do
    {:noreply, state}
  end

  #################### HANDLE INFO ####################

  ## SPAWN PARTICLES

  ## GET PARTICLES

  ################### VACATED ##############################
  @impl true
  def handle_info(:LIVE, %{hive_id: hive_id} = state) do
    state =
      if count_particles(hive_id) <= 0 do
        HiveEmitter.emit_hive_vacated(state)

        new_state = %HiveInit{
          state
          | hive_status: @hive_status_vacant,
            license_id: nil,
            license: nil
        }

        Process.send_after(self(), :CLAIM_LICENSE, 10_000)
        new_state
      else
        Process.send_after(self(), :LIVE, 2_000)
        state
      end

    {:noreply, state}
  end

  ##################### CLAIM LICENSE ######################
  @impl true
  def handle_info(:CLAIM_LICENSE, %{hive_id: hive_id} = state) do
    new_state =
      case HiveEmitter.try_reserve_license(state) do
        nil ->
          Process.send_after(self(), :CLAIM_LICENSE, 30_000)
          state

        %{license_id: license_id} = license ->
          Logger.warning(
            "License [#{license_id}] assigned to Hive [#{hive_id}], #{Colors.hive_theme(self())}"
          )

          new_state =
            %{
              state
              | license: license,
                license_id: license_id,
                hive_status: @hive_status_occupied
            }

          HiveEmitter.emit_hive_occupied(new_state)

          Process.send_after(self(), :LIVE, 5_000)
          new_state
      end

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
