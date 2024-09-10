defmodule Licenses.Service do
  @moduledoc """
  The service wrapper module for the swarm trainings cache.
  """
  use GenServer

  alias Colors, as: Colors
  alias Phoenix.PubSub, as: PubSub
  alias Schema.SwarmLicense, as: SwarmLicense
  alias Schema.SwarmLicense.Status, as: Status

  alias TrainSwarmProc.Facts, as: TrainSwarmProcFacts
  alias Scape.Facts, as: ScapeFacts

  alias TrainSwarmProc.InitializeLicense.EvtV1, as: Initialized
  alias TrainSwarmProc.ConfigureLicense.EvtV1, as: Configured
  alias TrainSwarmProc.PayLicense.EvtV1, as: Paid
  alias TrainSwarmProc.BlockLicense.EvtV1, as: LicenseBlocked
  alias TrainSwarmProc.ActivateLicense.EvtV1, as: Activated
  alias TrainSwarmProc.QueueLicense.EvtV1, as: LicenseQueued
  alias TrainSwarmProc.StartScape.EvtV1, as: ScapeStarted
  alias TrainSwarmProc.PauseScape.EvtV1, as: ScapePaused
  alias TrainSwarmProc.DetachScape.EvtV1, as: ScapeDetached

  alias Cachex, as: Cachex
  alias Edge.Init, as: EdgeInit
  alias Scape.Init, as: ScapeInit
  alias Caches, as: Caches

  require Logger
  import Flags

  @license_initialized_status Status.license_initialized()
  @license_configured_status Status.license_configured()
  @license_paid_status Status.license_paid()
  @licensed_activated_status Status.license_active()
  @license_blocked_status Status.license_blocked()
  @license_queued_status Status.license_queued()
  @license_reserved_status Status.license_reserved()

  @scape_started_status Status.scape_started()
  @scape_paused_status Status.scape_paused()
  @scape_detached_status Status.scape_detached()

  @license_facts TrainSwarmProcFacts.license_facts()
  @license_cache_updated_v1 TrainSwarmProcFacts.cache_updated_v1()
  # @swarm_license_cache_facts TrainSwarmProcFacts.cache_facts()

  @swarm_license_initialized_v1 TrainSwarmProcFacts.license_initialized()
  @swarm_license_configured_v1 TrainSwarmProcFacts.license_configured()
  @swarm_license_paid_v1 TrainSwarmProcFacts.license_paid()
  @swarm_license_blocked_v1 TrainSwarmProcFacts.license_blocked()
  @swarm_license_activated_v1 TrainSwarmProcFacts.license_activated()

  @scape_facts ScapeFacts.scape_facts()
  @license_queued_v1 ScapeFacts.license_queued_v1()
  @scape_started_v1 ScapeFacts.scape_started_v1()
  @scape_detached_v1 ScapeFacts.scape_detached_v1()
  @scape_paused_v1 ScapeFacts.scape_paused_v1()

  defp get_edge(%{edge: nil}), do: EdgeInit.default()
  defp get_edge(%{edge: edge}), do: edge

  defp check_queued_or_paused(%SwarmLicense{status: status}) do
    status
    |> Flags.has_any?([@license_queued_status, @scape_paused_status])
  end

  ################# INIT ###################
  @impl true
  def init(%{cache_file: path} = args) do
    Process.flag(:trap_exit, true)

    Logger.info(
      "Starting Licenses.Service with args #{inspect(args)} => #{Colors.scape_theme(self())}"
    )

    read_from_disk(path)

    Swai.PubSub
    |> PubSub.subscribe(@license_facts)

    Swai.PubSub
    |> PubSub.subscribe(@scape_facts)

    {:ok, args}
  end

  ################## API ##################
  def count,
    do:
      GenServer.call(
        __MODULE__,
        :count
      )

  def claim_license(hive),
    do:
      GenServer.call(
        __MODULE__,
        {:claim_license, hive}
      )

  def get_all,
    do:
      GenServer.call(
        __MODULE__,
        :get_all
      )

  def get_all_for_user(user_id),
    do:
      GenServer.call(
        __MODULE__,
        {:get_all_for_user, user_id}
      )

  def get_candidates(biotope_id),
    do:
      GenServer.call(
        __MODULE__,
        {:get_candidates, biotope_id}
      )

  def set_license_reserved(license),
    do:
      GenServer.cast(
        __MODULE__,
        {:set_license_reserved, license}
      )

  def set_license_presented(license),
    do:
      GenServer.cast(
        __MODULE__,
        {:set_license_presented, license}
      )

  ############ INTERNALS ###############
  defp notify_swarm_licenses_updated(cause) do
    save_to_disk()

    res =
      Swai.PubSub
      |> PubSub.broadcast!(@license_cache_updated_v1, cause)

    Logger.warning("Notified SwarmLicense Cache Updated #{inspect(cause)} => #{inspect(res)}")
  end

  def save_to_disk do
    GenServer.cast(
      __MODULE__,
      {:save_to_disk}
    )
  end

  def read_from_disk(path) do
    GenServer.cast(
      __MODULE__,
      {:read_from_disk, path}
    )
  end

  ################# SET_LICENSE_RESERVED #######
  @impl true
  def handle_cast({:set_license_reserved, %SwarmLicense{} = license}, state) do
    license = %SwarmLicense{
      license
      | status:
          license.status
          |> unset_all([@license_queued_status, @scape_paused_status])
          |> set(@license_reserved_status)
    }

    if :licenses_cache
       |> Cachex.update!(license.license_id, license) do
      notify_swarm_licenses_updated({:license, :set_license_reserved, license})
    end

    {:noreply, state}
  end

  ################# READ_FROM_DISK ##############
  @impl true
  def handle_cast({:read_from_disk, path}, state) do
    # We assume that the directory exists

    :licenses_cache
    |> Cachex.clear!()

    if File.exists?(path) do
      :licenses_cache
      |> Cachex.load!(path)
    end

    notify_swarm_licenses_updated({:license, :read_from_disk, path})

    {:noreply, state}
  end

  ################# SAVE_TO_DISK ##############
  @impl true
  def handle_cast({:save_to_disk}, %{cache_file: path} = state) do
    :licenses_cache
    |> Cachex.dump!(path)

    {:noreply, state}
  end

  ################# GET_CANDIDATES ##############
  @impl true
  def handle_call({:get_candidates, biotope_id}, _from, state) do
    {
      :reply,
      :licenses_cache
      |> Cachex.stream!()
      |> Stream.filter(fn {:entry, _key, _nil, _internal_id, lic} ->
        check_queued_or_paused(lic) && lic.biotope_id == biotope_id
      end)
      |> Stream.map(fn {:entry, _key, _nil, _internal_id, lic} -> lic end)
      |> Enum.to_list(),
      state
    }
  end

  ################# COUNT ##############
  @impl true
  def handle_call(:count, _from, state) do
    {
      :reply,
      :licenses_cache
      |> Cachex.count!(),
      state
    }
  end

  ################# CLAIM_LICENSE ##############
  @impl true
  def handle_call({:claim_license, %{biotope_id: qry_biotope_id} = _hive}, _from, state) do
    claimed_license =
      case :licenses_cache
           |> Cachex.stream!()
           |> Stream.filter(fn {:entry, _key, _nil, _internal_id,
                                %{biotope_id: found_biotope_id} = lic} ->
             qry_biotope_id == found_biotope_id && check_queued_or_paused(lic)
           end)
           |> Stream.map(fn {:entry, _key, _nil, _internal_id, lic} -> lic end)
           |> Enum.random() do
        nil ->
          nil

        license ->
          claimed =
            %SwarmLicense{
              license
              | status:
                  license.status
                  |> unset_all([@license_queued_status, @scape_paused_status])
                  |> set(@license_reserved_status)
            }

          :licenses_cache
          |> Cachex.update!(license.license_id, license)

          notify_swarm_licenses_updated({:license, :claim_license, license})
          claimed
      end

    {:reply, claimed_license, state}
  end

  ################# GET_ALL ##############
  @impl true
  def handle_call(:get_all, _from, state) do
    {
      :reply,
      :licenses_cache
      |> Cachex.stream!()
      |> Enum.map(fn {:entry, _key, _nil, _internal_id, st} -> st end),
      state
    }
  end

  ################# GET_ALL_FOR_USER ##############
  @impl true
  def handle_call({:get_all_for_user, user_id}, _from, state) do
    {
      :reply,
      :licenses_cache
      |> Cachex.stream!()
      |> Enum.filter(fn {:entry, _key, _nil, _internal_id, lic} ->
        lic.user_id == user_id
      end)
      |> Enum.map(fn {:entry, _key, _nil, _internal_id, lic} -> lic end),
      state
    }
  end

  #################### TERMINATE ##################
  @impl true
  def terminate(reason, %{cache_file: path} = _state) do
    "Terminating SwarmLicense.Service. Reason: #{inspect(reason)}"

    res =
      :licenses_cache
      |> Cachex.dump!(path)

    "Dumped SwarmLicense Cache to [#{path}] => #{inspect(res)}"
    :ok
  end

  ################# LICENSE_INITIALIZED ###########
  @impl true
  def handle_info(
        {
          @swarm_license_initialized_v1,
          %Initialized{agg_id: agg_id, version: _version, payload: payload} = evt,
          metadata
        },
        state
      ) do
    "ADDING SwarmLicense due to #{inspect(evt)} with metadata #{inspect(metadata)}"

    seed = %SwarmLicense{
      license_id: agg_id,
      status: @license_initialized_status
    }

    case SwarmLicense.from_map(seed, payload) do
      {:ok, %SwarmLicense{} = license} ->
        if :licenses_cache
           |> Cachex.put!(agg_id, license) do
          notify_swarm_licenses_updated({:license, @swarm_license_initialized_v1, license})
        end

      {:error, _reason} ->
        Logger.error("Failed to create SwarmLicense from #{inspect(payload)}")
    end

    {:noreply, state}
  end

  ## Handle License Configured
  @impl true
  def handle_info(
        {
          @swarm_license_configured_v1,
          %Configured{agg_id: agg_id, payload: configuration} = _evt,
          _metadata
        },
        state
      ) do
    license =
      :licenses_cache
      |> Cachex.get!(agg_id)

    case SwarmLicense.from_map(license, configuration) do
      {:ok, license} ->
        license = %SwarmLicense{
          license
          | status:
              license.status
              |> set(@license_configured_status)
        }

        if :licenses_cache
           |> Cachex.update!(agg_id, license) do
          notify_swarm_licenses_updated({:license, @swarm_license_configured_v1, license})
        end

      {:error, _reason} ->
        Logger.error("Failed to update SwarmLicense from #{inspect(configuration)}")
    end

    {:noreply, state}
  end

  ################### HANDLE_LICENSE_PAID ###################
  @impl true
  def handle_info(
        {
          @swarm_license_paid_v1,
          %Paid{agg_id: agg_id, version: _version, payload: _payment} = evt,
          _metadata
        },
        state
      ) do
    "LICENSE PAID with event #{inspect(evt)}"

    license =
      :licenses_cache
      |> Cachex.get!(agg_id)

    license = %SwarmLicense{
      license
      | status:
          license.status
          |> unset(@license_blocked_status)
          |> set(@license_paid_status)
    }

    if :licenses_cache
       |> Cachex.update!(agg_id, license) do
      notify_swarm_licenses_updated({:license, @swarm_license_paid_v1, license})
    end

    {:noreply, state}
  end

  ######################## LICENSE ACTIVATED ##############################
  @impl true
  def handle_info(
        {@swarm_license_activated_v1, %Activated{agg_id: agg_id} = evt, _metadata},
        state
      ) do
    "LICENSE ACTIVATED with event #{inspect(evt)}"

    license =
      :licenses_cache
      |> Cachex.get!(agg_id)

    license = %SwarmLicense{
      license
      | status:
          license.status
          |> unset(@license_blocked_status)
          |> set(@licensed_activated_status)
    }

    if :licenses_cache
       |> Cachex.update!(agg_id, license) do
      notify_swarm_licenses_updated({:license, @swarm_license_activated_v1, license})
    end

    {:noreply, state}
  end

  ################### SCAPE_QUEUED ###################
  @impl true
  def handle_info(
        {@license_queued_v1, %LicenseQueued{agg_id: agg_id} = evt, _metadata},
        state
      ) do
    "SCAPE QUEUED with event #{inspect(evt)}"

    license =
      :licenses_cache
      |> Cachex.get!(agg_id)

    license = %SwarmLicense{
      license
      | status:
          license.status
          |> unset_all([@scape_started_status, @scape_paused_status])
          |> set(@license_queued_status)
    }

    if :licenses_cache
       |> Cachex.update!(agg_id, license) do
      notify_swarm_licenses_updated({:license, @license_queued_v1, license})
    end

    {:noreply, state}
  end

  ################### HANDLE_LICENSE_BLOCKED ###################
  @impl true
  def handle_info(
        {@swarm_license_blocked_v1,
         %LicenseBlocked{agg_id: agg_id, version: _version, payload: block_info} = evt,
         _metadata},
        state
      ) do
    "LICENSE BLOCKED with event #{inspect(evt)}"

    license =
      :licenses_cache
      |> Cachex.get!(agg_id)

    license = %SwarmLicense{
      license
      | status:
          license.status
          |> set(@license_blocked_status)
          |> unset(@license_paid_status)
    }

    if :licenses_cache
       |> Cachex.update!(agg_id, license) do
      notify_swarm_licenses_updated({:license, @swarm_license_blocked_v1, license, block_info})
    end

    {:noreply, state}
  end

  ################### SCAPE STARTED #####################################
  @impl true
  def handle_info(
        {
          @scape_started_v1,
          %ScapeStarted{agg_id: agg_id, version: _version, payload: %{edge_id: edge_id} = payload} =
            evt,
          _metadata
        },
        state
      ) do
    "SCAPE STARTED with event #{inspect(evt)}"

    case ScapeInit.from_map(%ScapeInit{}, payload) do
      {:ok, scape} ->
        _edge = get_edge(scape)
        Logger.debug("ScapeStarted: #{inspect(scape)}")

        license =
          :licenses_cache
          |> Cachex.get!(agg_id)

        license =
          %SwarmLicense{
            license
            | edge_id: edge_id,
              status:
                license.status
                |> unset_all([@license_queued_status, @scape_paused_status])
                |> set(@scape_started_status)
          }

        if :licenses_cache
           |> Cachex.update!(agg_id, license) do
          notify_swarm_licenses_updated({:license, @scape_started_v1, license})
        end

      {:error, reason} ->
        Logger.error("Failed to create Scape from #{inspect(payload)} => #{inspect(reason)}")
    end

    {:noreply, state}
  end

  ######################## SCAPE DETACHED ###########################
  @impl true
  def handle_info(
        {@scape_detached_v1, %ScapeDetached{agg_id: agg_id} = evt, _metadata},
        state
      ) do
    "SCAPE DETACHED with event #{inspect(evt)}"

    license =
      :licenses_cache
      |> Cachex.get!(agg_id)

    license =
      %SwarmLicense{
        license
        | edge_id: "N/A",
          status:
            license.status
            |> unset_all([@scape_started_status, @license_queued_status])
            |> set_all([@scape_detached_status, @scape_paused_status, @license_queued_status])
      }

    if :licenses_cache
       |> Cachex.update!(agg_id, license) do
      notify_swarm_licenses_updated({:license, @scape_detached_v1, license})
    end

    {:noreply, state}
  end

  ######################## SCAPE PAUSED ############################
  @impl true
  def handle_info(
        {@scape_paused_v1, %ScapePaused{agg_id: agg_id} = evt, _metadata},
        state
      ) do
    "SCAPE PAUSED with event #{inspect(evt)}"

    license =
      :licenses_cache
      |> Cachex.get!(agg_id)

    license =
      %SwarmLicense{
        license
        | status:
            license.status
            |> set(@scape_paused_status)
            |> unset(@scape_started_status)
      }

    if :licenses_cache
       |> Cachex.update!(agg_id, license) do
      notify_swarm_licenses_updated({:license, @scape_paused_v1, license})
    end

    {:noreply, state}
  end

  ## Handle Info Falltrhough
  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  ################### PLUMBING ###################
  def child_spec(init_arg),
    do: %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init_arg]},
      type: :worker
    }

  def start_link(init_args),
    do:
      GenServer.start_link(
        __MODULE__,
        init_args,
        name: __MODULE__
      )
end
