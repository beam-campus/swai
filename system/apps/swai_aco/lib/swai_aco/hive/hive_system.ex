defmodule Hive.System do
  @moduledoc """
  This module is responsible for managing the particles in the system.
  """
  use GenServer

  alias Hive.Emitter, as: HiveEmitter
  alias Hive.Init, as: HiveInit
  alias Hive.Status, as: HiveStatus
  alias Particle.Init, as: Particle

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
    case Supervisor.count_children(via_sup(hive_id)) do
      %{active: count} when is_integer(count) ->
        count

      {:error, reason} ->
        Logger.error("Failed to count particles in Hive [#{hive_id}]: #{inspect(reason)}")
        0
    end
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

  #################### SPAWN PARTICLE ####################
  defp do_spawn_particle(%{hive_id: hive_id} = hive) do
    particle_id = "pt-#{UUID.uuid4()}"
    seed = %Particle{particle_id: particle_id}

    {:ok, particle_init} =
      Particle.from_map(seed, hive)

    case Supervisor.start_child(
           via_sup(hive_id),
           {SwaiAco.Particle.System, particle_init}
         ) do
      {:ok, _pid} ->
        Logger.debug("Particle spawned in Hive [#{hive_id}]")

      {:error, reason} ->
        Logger.error("Failed to spawn particle in Hive [#{hive_id}]: #{inspect(reason)}")
    end

    hive
  end

  defp do_vacate_hive(hive) do
    hive =
      %HiveInit{
        hive
        | hive_status: @hive_status_vacant,
          user_id: nil,
          license_id: nil,
          license: nil
      }

    HiveEmitter.emit_hive_vacated(hive)
    hive
  end

  ################### LIVE! ##############################
  @impl true
  def handle_info(
        :LIVE,
        %HiveInit{
          hive_id: hive_id,
          particles_cap: particles_cap,
          hive_status: @hive_status_occupied
        } = hive
      ) do
    new_hive =
      cond do
        count_particles(hive_id) == 0 ->
          Process.send_after(self(), :CLAIM_LICENSE, 10_000)
          do_vacate_hive(hive)

        count_particles(hive_id) < particles_cap ->
          Process.send_after(self(), :LIVE, 2_000)
          do_spawn_particle(hive)

        true ->
          Process.send_after(self(), :LIVE, 2_000)
          hive
      end

    {:noreply, new_hive}
  end

  ##################### CLAIM LICENSE ######################
  @impl true
  def handle_info(
        :CLAIM_LICENSE,
        %HiveInit{
          hive_id: hive_id,
          scape_id: scape_id,
          license: nil,
          hive_status: @hive_status_vacant
        } = hive
      ) do
    new_hive =
      case HiveEmitter.try_reserve_license(hive) do
        nil ->
          Process.send_after(self(), :CLAIM_LICENSE, 10_000)
          hive

        %{license_id: license_id, user_id: user_id} = license ->
          Logger.warning(
            "License [#{license_id}] for user [#{user_id}] assigned to Hive [#{hive_id}], #{Colors.hive_theme(self())}"
          )

          new_hive =
            %HiveInit{
              hive
              | license: license,
                scape_id: scape_id,
                user_id: user_id,
                license_id: license_id,
                hive_status: @hive_status_occupied
            }

          HiveEmitter.emit_hive_occupied(new_hive)
          Process.send_after(self(), :START_SWARM, 2_000)
          new_hive
      end

    {:noreply, new_hive}
  end

  ##################### START SWARM ######################
  @impl true
  def handle_info(:START_SWARM, %{hive_id: hive_id} = hive) do
    Logger.debug("Starting Swarm in Hive [#{hive_id}]")

    # new_hive =
    #   do_spawn_particle(hive) TODO: Implement Swarm Spawning ##########

    new_hive = hive

    Process.send_after(self(), :LIVE, 2_000)
    {:noreply, new_hive}
  end

  ################### PLUMBING ###################
  @impl true
  def terminate(_reason, hive) do
    Logger.debug("hive.system terminated")
    HiveEmitter.emit_hive_detached(hive)
    :ok
  end

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
