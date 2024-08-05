defmodule SwarmLicenses.Service do
  @moduledoc """
  The service wrapper module for the swarm trainings cache.
  """
  use GenServer

  alias Colors, as: Colors
  alias Phoenix.PubSub, as: PubSub
  alias Schema.SwarmLicense, as: SwarmLicense
  alias Schema.SwarmLicense.Status, as: Status
  alias TrainSwarmProc.Facts, as: Facts

  alias TrainSwarmProc.Initialize.EvtV1, as: Initialized
  alias TrainSwarmProc.Initialize.PayloadV1, as: Initialization

  alias TrainSwarmProc.Configure.EvtV1, as: Configured
  alias TrainSwarmProc.Configure.PayloadV1, as: Configuration

  alias TrainSwarmProc.PayLicense.EvtV1, as: Paid
  alias TrainSwarmProc.PayLicense.PayloadV1, as: Payment

  alias TrainSwarmProc.Activate.EvtV1, as: Activated
  alias TrainSwarmProc.Activate.PayloadV1, as: Activation

  alias TrainSwarmProc.QueueScape.EvtV1, as: ScapeQueued
  alias Scape.Init, as: ScapeInit

  alias Cachex, as: Cachex

  alias Swai.Workspace, as: Workspace

  require Logger

  @license_initialized_status Status.license_initialized()
  @license_configured_status Status.license_configured()
  @license_paid_status Status.license_paid()
  @licensed_activated_status Status.license_active()
  @scape_queued_status Status.scape_queued()

  @swarm_licenses_updated_v1 Facts.cache_updated_v1()

  @swarm_license_initialized_v1 Facts.license_initialized()
  @swarm_license_configured_v1 Facts.license_configured()
  @swarm_license_paid_v1 Facts.license_paid()
  @swarm_license_activated_v1 Facts.license_activated()

  @user_id "user_id"
  @biotope_name "biotope_name"
  @swarm_size "swarm_size"

  ################## API ##################
  def count(),
    do:
      GenServer.call(
        __MODULE__,
        :count
      )

  def get_all(),
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

  ############ INTERNALS ###############
  defp notify_swarm_licenses_updated(cause) do
    res =
      Swai.PubSub
      |> PubSub.broadcast!(
        @swarm_licenses_updated_v1,
        cause
      )

    Logger.debug("Notified SwarmLicense Cache Updated #{inspect(cause)} => #{inspect(res)}")
  end

  defp init_cache_from_store() do
    Logger.info("Initializing SwarmLicense Cache from Store")

    :swarm_licenses_cache
    |> Cachex.clear!()

    Workspace.list_swarm_licenses()
    |> Enum.each(fn st ->
      :swarm_licenses_cache
      |> Cachex.put!(st.license_id, st)
    end)
  end

  ################# COUNT ##############
  @impl true
  def handle_call(:count, _from, state) do
    {
      :reply,
      :swarm_licenses_cache
      |> Cachex.count!(),
      state
    }
  end

  ################# GET_ALL ##############
  @impl true
  def handle_call(:get_all, _from, state) do
    {
      :reply,
      :swarm_licenses_cache
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
      :swarm_licenses_cache
      |> Cachex.stream!()
      |> Enum.filter(fn {:entry, _key, _nil, _internal_id, st} ->
        st.user_id == user_id
      end)
      |> Enum.map(fn {:entry, _key, _nil, _internal_id, st} -> st end),
      state
    }
  end

  ################# INIT ###################
  @impl true
  def init(args) do
    Logger.info(
      "Starting SwarmLicense.Service with args #{inspect(args)} => #{Colors.region_theme(self())}"
    )

    init_cache_from_store()

    Swai.PubSub
    |> PubSub.subscribe(@swarm_license_initialized_v1)

    Swai.PubSub
    |> PubSub.subscribe(@swarm_license_configured_v1)

    Swai.PubSub
    |> PubSub.subscribe(@swarm_license_paid_v1)

    Swai.PubSub
    |> PubSub.subscribe(@swarm_license_activated_v1)

    {:ok, %{}}
  end

  ################# HANDLE_INITIALIZED ###########
  @impl true
  def handle_info(
        {
          @swarm_license_initialized_v1,
          %Initialized{
            agg_id: agg_id,
            version: _version,
            payload: payload
          } = evt,
          metadata
        },
        state
      ) do
    Logger.debug("ADDING SwarmLicense due to #{inspect(evt)} with metadata #{inspect(metadata)}")
    seed = %SwarmLicense{license_id: agg_id, status: @license_initialized_status}

    case SwarmLicense.from_map(seed, payload) do
      {:ok, %SwarmLicense{} = st} ->
        if :swarm_licenses_cache
           |> Cachex.put!(agg_id, st) do
          notify_swarm_licenses_updated({@swarm_license_initialized_v1, st, metadata})
        end

      {:error, _reason} ->
        Logger.error("Failed to create SwarmLicense from #{inspect(payload)}")
    end

    {:noreply, state}
  end

  ################# HANDLE_CONFIGURED ###########
  @impl true
  def handle_info(
        {
          @swarm_license_configured_v1,
          %Configured{
            agg_id: agg_id,
            version: _version,
            payload: configuration
          } = _evt,
          metadata
        },
        state
      ) do
    st =
      :swarm_licenses_cache
      |> Cachex.get!(agg_id)

    case SwarmLicense.from_map(st, configuration) do
      {:ok, st} ->
        st = %SwarmLicense{st | status: @license_configured_status}

        if :swarm_licenses_cache
           |> Cachex.update!(agg_id, st) do
          notify_swarm_licenses_updated({
            @swarm_license_configured_v1,
            st,
            metadata
          })
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
          %Paid{
            agg_id: agg_id,
            version: _version,
            payload: payment
          } = evt
        },
        state
      ) do
    Logger.debug("LICENSE PAID with event #{inspect(evt)}")

    st =
      :swarm_licenses_cache
      |> Cachex.get!(agg_id)

    st = %SwarmLicense{st | status: @license_paid_status}

    if :swarm_licenses_cache
       |> Cachex.update!(agg_id, st) do
      notify_swarm_licenses_updated({@swarm_license_paid_v1, st, payment})
    end

    {:noreply, state}
  end

  ######################## LICENSE ACTIVATED ##############################
  @impl true
  def handle_info(
        {
          @swarm_license_activated_v1,
          %Activated{
            agg_id: agg_id,
            version: _version,
            payload: _payload
          } = evt
        },
        state
      ) do
    Logger.debug("LICENSE ACTIVATED with event #{inspect(evt)}")

    st =
      :swarm_licenses_cache
      |> Cachex.get!(agg_id)

    st = %SwarmLicense{st | status: @licensed_activated_status}

    if :swarm_licenses_cache
       |> Cachex.update!(agg_id, st) do
      notify_swarm_licenses_updated({@swarm_license_activated_v1, st, evt})
    end

    {:noreply, state}
  end

  ################### HANDLE_SCAPE_QUEUED ###################
  @impl true
  def handle_info(
        {
          @scape_queued_status,
          %ScapeQueued{
            agg_id: agg_id,
            version: _version,
            payload: _payload
          } = evt
        },
        state
      ) do
    Logger.debug("SCAPE QUEUED with event #{inspect(evt)}")

    st =
      :swarm_licenses_cache
      |> Cachex.get!(agg_id)

    st = %SwarmLicense{st | status: @scape_queued_status}

    if :swarm_licenses_cache
       |> Cachex.update!(agg_id, st) do
      notify_swarm_licenses_updated({@scape_queued_status, st, evt})
    end

    {:noreply, state}
  end

  ################# HANDLE_UNHANDLED_EVENTS ######
  @impl true
  def handle_info(msg, _state) do
    Logger.warning("Unhandled event #{inspect(msg)}")
    {:noreply, "Unhandled event #{inspect(msg)}"}
  end

  ################### PLUMBING ###################
  def child_spec(init_arg),
    do: %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init_arg]},
      type: :worker
    }

  def start_link(args),
    do:
      GenServer.start_link(
        __MODULE__,
        [args],
        name: __MODULE__
      )
end
