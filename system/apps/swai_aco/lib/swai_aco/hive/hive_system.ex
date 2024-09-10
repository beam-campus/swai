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

  def present_license(hive_id, license),
    do:
      GenServer.cast(
        via(hive_id),
        {:present_license, license}
      )

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

    #    Process.send_after(self(), :AUCTION_OPENED, 5_000)

    Process.send_after(self(), :RESERVE_LICENSE, 30_000)

    {:ok, %{hive: hive_init, auction: []}}
  end

  #################### HANDLE CAST ####################
  ## Accept License
  @impl true
  def handle_cast(
        {:present_license, %{license_id: license_id} = license},
        %{
          hive: %{hive_id: hive_id, status: @hive_status_vacant},
          auction: auction
        } = state
      ) do
    new_state = %{state | auction: [license | auction]}
    Logger.alert("License #{license_id} was added to Hive Auction #{hive_id}")
    {:noreply, new_state}
  end

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
  def handle_info(:AUCTION_OPENED, %{hive: hive} = state) do
    new_hive = %HiveInit{
      hive
      | status: @hive_status_vacant,
        license_id: nil,
        license: nil
    }

    new_state = %{state | hive: new_hive, auction: []}
    HiveEmitter.emit_hive_vacated(new_hive)
    Process.send_after(self(), :AUCTION_CLOSED, 60_000)
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:TICK, %{hive: %{hive_id: hive_id}} = state) do
    if count_particles(hive_id) <= 0 do
      Process.send_after(self(), :AUCTION_OPENED, 10_000)
    end

    Process.send_after(self(), :TICK, 30_000)
    {:noreply, state}
  end

  ## AUCTION CLOSED
  @impl true
  def handle_info(
        :AUCTION_CLOSED,
        %{
          hive: %{hive_id: hive_id} = hive,
          auction: auction
        } = state
      ) do
    new_state =
      case auction do
        [] ->
          Logger.info("No licenses in auction for hive #{hive_id}")
          state

        licenses ->
          Logger.info("Auction closed for hive #{hive_id} => #{inspect(licenses)}")

          %{license_id: license_id} =
            license =
            licenses
            |> Enum.random()

          new_state = %{
            state
            | hive: %HiveInit{
                hive
                | status: @hive_status_occupied,
                  license_id: license_id,
                  license: license
              },
              auction: []
          }

          HiveEmitter.emit_hive_occupied(new_state.hive)
      end

    {:noreply, new_state}
  end

  ## CLAIM LICENSE
  @impl true
  def handle_info(:RESERVE_LICENSE, %{hive: %{hive_id: hive_id} = hive} = state) do
    new_state =
      case HiveEmitter.try_reserve_license(hive) do
        nil ->
          Process.send_after(self(), :RESERVE_LICENSE, 30_000)
          state

        %{license_id: license_id} = license ->
          Logger.warning("License [#{license_id}] assigned to Hive [#{hive_id}]")

          %{hive: new_hive} =
            new_state =
            %{
              state
              | hive: %{
                  hive
                  | license: license,
                    license_id: license_id,
                    status: @hive_status_occupied
                }
            }

          HiveEmitter.emit_hive_occupied(new_hive)
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
