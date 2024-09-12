defmodule Licenses.Service do
  @moduledoc """
  The service wrapper module for the swarm trainings cache.
  """
  use GenServer

  alias Colors, as: Colors
  alias Phoenix.PubSub, as: PubSub
  alias Schema.SwarmLicense, as: SwarmLicense
  alias Schema.SwarmLicense.Status, as: Status

  alias License.Facts, as: LicenseFacts
  alias Scape.Facts, as: ScapeFacts

  alias Arenas.Service, as: Arenas
  alias Edges.Service, as: Edges
  alias Hives.Service, as: Hives
  alias Scapes.Service, as: Scapes

  alias TrainSwarmProc.ActivateLicense.EvtV1, as: Activated
  alias TrainSwarmProc.BlockLicense.EvtV1, as: LicenseBlocked
  alias TrainSwarmProc.ConfigureLicense.EvtV1, as: Configured
  alias TrainSwarmProc.InitializeLicense.EvtV1, as: Initialized
  alias TrainSwarmProc.PauseLicense.EvtV1, as: LicensePaused
  alias TrainSwarmProc.PayLicense.EvtV1, as: Paid
  alias TrainSwarmProc.QueueLicense.EvtV1, as: LicenseQueued
  alias TrainSwarmProc.ReserveLicense.EvtV1, as: LicenseReserved
  alias TrainSwarmProc.StartLicense.EvtV1, as: LicenseStarted

  alias Cachex, as: Cachex

  require Logger
  import Flags

  @license_initialized_status Status.license_initialized()
  @license_configured_status Status.license_configured()
  @license_paid_status Status.license_paid()
  @licensed_activated_status Status.license_active()
  @license_blocked_status Status.license_blocked()
  @license_queued_status Status.license_queued()
  @license_reserved_status Status.license_reserved()
  @license_started_status Status.license_started()
  @license_paused_status Status.license_paused()

  @license_facts LicenseFacts.license_facts()
  @licenses_cache_facts LicenseFacts.licenses_cache_facts()

  @license_initialized_v1 LicenseFacts.license_initialized()
  @license_configured_v1 LicenseFacts.license_configured()
  @license_paid_v1 LicenseFacts.license_paid()
  @license_blocked_v1 LicenseFacts.license_blocked()
  @license_activated_v1 LicenseFacts.license_activated()
  @license_queued_v1 LicenseFacts.license_queued()
  @license_reserved_v1 LicenseFacts.license_reserved()
  @license_started_v1 LicenseFacts.license_started()
  @license_paused_v1 LicenseFacts.license_paused()

  @scape_facts ScapeFacts.scape_facts()

  defp get_edge(%{edge: edge}), do: edge

  defp check_queued_or_paused(%SwarmLicense{status: status}) do
    status
    |> Flags.has_any?([@license_queued_status, @license_paused_status])
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
      |> PubSub.broadcast!(@licenses_cache_facts, cause)

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
          |> unset_all([@license_queued_status, @license_paused_status])
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
    candidates =
      :licenses_cache
      |> Cachex.stream!()
      |> Stream.filter(fn {:entry, _key, _nil, _internal_id, lic} ->
        check_queued_or_paused(lic) && lic.biotope_id == qry_biotope_id
      end)
      |> Stream.map(fn {:entry, _key, _nil, _internal_id, lic} -> lic end)
      |> Enum.to_list()

    claimed_license =
      case Enum.any?(candidates) do
        false ->
          nil

        true ->
          %{license_id: license_id} =
            license =
            Enum.random(candidates)

          claimed =
            %SwarmLicense{
              license
              | status:
                  license.status
                  |> unset_all([@license_queued_status, @license_paused_status])
                  |> set(@license_reserved_status)
            }

          :licenses_cache
          |> Cachex.update!(license_id, claimed)

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
    decorated_licenses =
      :licenses_cache
      |> Cachex.stream!()
      |> Stream.filter(fn {:entry, _key, _nil, _internal_id, lic} ->
        lic.user_id == user_id
      end)
      |> Stream.map(fn {:entry, _key, _nil, _internal_id, lic} -> lic end)
      |> Stream.map(&Edges.hydrate/1)
      |> Stream.map(&Scapes.hydrate/1)
      |> Stream.map(&Hives.hydrate/1)
      |> Stream.map(&Arenas.hydrate/1)
      |> Enum.to_list()

    {:reply, decorated_licenses, state}
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
          @license_initialized_v1,
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
        :licenses_cache
        |> Cachex.put!(agg_id, license)

        notify_swarm_licenses_updated({:license, @license_initialized_v1, license})

      {:error, _reason} ->
        Logger.error("Failed to create SwarmLicense from #{inspect(payload)}")
    end

    {:noreply, state}
  end

  ################### LICENSE CONFIGURED ###################
  @impl true
  def handle_info(
        {
          @license_configured_v1,
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

        :licenses_cache
        |> Cachex.put!(agg_id, license)

        notify_swarm_licenses_updated({:license, @license_configured_v1, license})

      {:error, _reason} ->
        Logger.error("Failed to update SwarmLicense from #{inspect(configuration)}")
    end

    {:noreply, state}
  end

  ################### LICENSE PAID ###################
  @impl true
  def handle_info(
        {
          @license_paid_v1,
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

    :licenses_cache
    |> Cachex.put!(agg_id, license)

    notify_swarm_licenses_updated({:license, @license_paid_v1, license})

    {:noreply, state}
  end

  ######################## LICENSE ACTIVATED ##############################
  @impl true
  def handle_info(
        {@license_activated_v1, %Activated{agg_id: agg_id} = evt, _metadata},
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

    :licenses_cache
    |> Cachex.put!(agg_id, license)

    notify_swarm_licenses_updated({:license, @license_activated_v1, license})

    {:noreply, state}
  end

  ################### LICENSE_QUEUED ###################
  @impl true
  def handle_info(
        {@license_queued_v1, %LicenseQueued{agg_id: agg_id} = evt, _metadata},
        state
      ) do
    "LICENSE QUEUED with event #{inspect(evt)}"

    license =
      :licenses_cache
      |> Cachex.get!(agg_id)

    license = %SwarmLicense{
      license
      | status:
          license.status
          |> unset_all([
            @license_started_status,
            @license_paused_status,
            @license_reserved_status
          ])
          |> set(@license_queued_status)
    }

    :licenses_cache
    |> Cachex.put!(agg_id, license)

    notify_swarm_licenses_updated({:license, @license_queued_v1, license})

    {:noreply, state}
  end

  ################### LICENSE BLOCKED ###################
  @impl true
  def handle_info(
        {@license_blocked_v1,
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

    :licenses_cache
    |> Cachex.put!(agg_id, license)

    notify_swarm_licenses_updated({:license, @license_blocked_v1, license, block_info})

    {:noreply, state}
  end

  ################### LICENSE STARTED #####################################
  @impl true
  def handle_info(
        {
          @license_started_v1,
          %LicenseStarted{
            agg_id: agg_id,
            version: _version,
            payload: payload
          } =
            evt,
          _metadata
        },
        state
      ) do
    "LICENSE STARTED with event #{inspect(evt)}"

    case SwarmLicense.from_map(%SwarmLicense{}, payload) do
      {:ok, start_info} ->
        stored_license =
          :licenses_cache
          |> Cachex.get!(agg_id)

        new_license =
          %SwarmLicense{
            start_info
            | status:
                stored_license.status
                |> unset_all([
                  @license_queued_status,
                  @license_paused_status,
                  @license_reserved_status
                ])
                |> set(@license_started_status)
          }

        :licenses_cache
        |> Cachex.put!(agg_id, new_license)

        notify_swarm_licenses_updated({:license, @license_started_v1, new_license})

      {:error, reason} ->
        Logger.error("Failed to create Scape from #{inspect(payload)} => #{inspect(reason)}")
    end

    {:noreply, state}
  end

  ######################## LICENSE PAUSED ############################
  @impl true
  def handle_info(
        {@license_paused_v1, %LicensePaused{agg_id: agg_id} = evt, _metadata},
        state
      ) do
    "LICENSE PAUSED with event #{inspect(evt)}"

    license =
      :licenses_cache
      |> Cachex.get!(agg_id)

    license =
      %SwarmLicense{
        license
        | status:
            license.status
            |> set(@license_paused_status)
            |> unset_all([
              @license_started_status,
              @license_reserved_status,
              @license_queued_status
            ])
      }

    :licenses_cache
    |> Cachex.put!(agg_id, license)

    notify_swarm_licenses_updated({:license, @license_paused_v1, license})

    {:noreply, state}
  end

  ################### LICENSE RESERVED ###################
  @impl true
  def handle_info(
        {@license_reserved_v1, %LicenseReserved{agg_id: agg_id} = evt, _metadata},
        state
      ) do
    "LICENSE RESERVED with event #{inspect(evt)}"

    license =
      :licenses_cache
      |> Cachex.get!(agg_id)

    license =
      %SwarmLicense{
        license
        | status:
            license.status
            |> set(@license_reserved_status)
            |> unset_all([
              @license_started_status,
              @license_paused_status,
              @license_queued_status
            ])
      }

    :licenses_cache
    |> Cachex.put!(agg_id, license)

    notify_swarm_licenses_updated({:license, @license_reserved_v1, license})

    {:noreply, state}
  end

  ####################### HANDLE INFO FALLTHROUGH #######################
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
