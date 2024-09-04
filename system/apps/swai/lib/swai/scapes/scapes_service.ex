defmodule Scapes.Service do
  use GenServer

  @moduledoc """
  Scapes.Service contains the GenServer for the Server.
  """

  require Cachex
  require Logger

  alias Phoenix.PubSub, as: PubSub
  alias Scape.Facts, as: ScapeFacts
  alias Scape.Init, as: ScapeInit
  alias Schema.SwarmLicense.Status, as: LicenseStatus

  @scape_facts ScapeFacts.scape_facts()

  @initializing_scape_v1 ScapeFacts.initializing_scape_v1()
  @scape_initialized_v1 ScapeFacts.scape_initialized_v1()
  @scape_detached_v1 ScapeFacts.scape_detached_v1()
  @scape_started_v1 ScapeFacts.scape_started_v1()

  # @edge_detached_v1 EdgeFacts.edge_detached_v1()
  @scapes_cache_updated_v1 ScapeFacts.scapes_cache_updated_v1()

  @scape_started_status LicenseStatus.scape_started()
  # @scape_paused_status LicenseStatus.scape_paused()
  # @scape_completed_status LicenseStatus.scape_completed()
  # @scape_cancelled_status LicenseStatus.scape_cancelled()
  # @scape_initializing_status LicenseStatus.scape_initializing()
  # @scape_initialized_status LicenseStatus.scape_initialized()

  ############################ INIT ##############################
  @impl true
  def init(init_args) do
    Logger.info("STARTED Scapes.Service. #{inspect(self())} LISTENING for #{@scape_facts}")

    Swai.PubSub
    |> PubSub.subscribe(@scape_facts)

    {:ok, init_args}
  end

  #################### PUBLIC API ##################
  def get_all(),
    do:
      GenServer.call(
        __MODULE__,
        :get_all
      )

  def get_stream(),
    do:
      GenServer.call(
        __MODULE__,
        :get_stream
      )

  def get_summary(),
    do:
      GenServer.call(
        __MODULE__,
        :get_summary
      )

  def get_for_edge(edge_id),
    do:
      GenServer.call(
        __MODULE__,
        {:get_for_edge, edge_id}
      )

  def save_scape(scape_init) do
    GenServer.cast(
      __MODULE__,
      {:save_scape, scape_init}
    )
  end

  def count() do
    GenServer.call(
      __MODULE__,
      {:count}
    )
  end

  #################### HANDLE CALL ##################
  @impl true
  def handle_call({:count}, _from, state) do
    result =
      :scapes_cache
      |> Cachex.stream!()
      |> Enum.count()

    {:reply, result, state}
  end

  #################### SAVE_SCAPE ##################
  @impl true
  def handle_cast({:save_scape, %{scape_id: scape_id} = scape_init}, state) do
    case :scapes_cache
         |> Cachex.get!(scape_id) do
      {:ok, nil} ->
        Logger.info("Scape saved: #{inspect(scape_init)}")

      {:ok, _} ->
        :scapes_cache
        |> Cachex.put!(scape_id, scape_init)

        Logger.info("Scape updated: #{inspect(scape_init)}")

      {:error, _} ->
        Logger.error("Failed to save Scape: #{inspect(scape_init)}")
    end

    :scapes_cache
    |> Cachex.put!(scape_init.scape_id, scape_init)

    {:noreply, state}
  end

  #################### UPDATE_SCAPE_STATUS  ##################
  @impl true
  def handle_cast({:update_scape_status, status}, state),
    do: {:noreply, %{state | scape_status: status}}

  #################### GET ALL ###############################
  @impl true
  def handle_call(:get_all, _from, state) do
    result =
      :scapes_cache
      |> Cachex.stream!()
      |> Enum.map(fn {:entry, _id, _internal_key, _nil, scape} -> scape end)

    {:reply, result, state}
  end

  #################### GET STREAM ###############################
  @impl true
  def handle_call(:get_stream, _from, state) do
    result =
      :scapes_cache
      |> Cachex.stream!()

    {:reply, result, state}
  end

  #################### GET SUMMARY ###############################
  @impl true
  def handle_call(:get_summary, _from, %ScapeInit{scape_id: scape_id} = state) do
    result =
      :scapes_cache
      |> Cachex.stream!()
      |> Stream.map(fn {:entry, _, _, _, scape} -> scape end)
      |> Enum.reduce(%{}, fn _scape, acc -> Map.update(acc, scape_id, 1, &(&1 + 1)) end)
      |> Map.to_list()
      |> Enum.sort()

    {:reply, result, state}
  end

  ################# GET_FOR_EDGE ##############
  @impl true
  def handle_call({:get_for_edge, edge_id}, _from, state) do
    case :scapes_cache
         |> Cachex.stream!()
         |> Stream.filter(fn {:entry, _key, _nil, _internal_id, scape} ->
           scape.edge_id == edge_id
         end)
         |> Enum.map(fn {:entry, _key, _nil, _internal_id, scape} -> scape end) do
      [] ->
        {:reply, [], state}

      scapes ->
        {:reply, scapes, state}
    end
  end

  ####################### INITIALIZING SCAPE #######################
  @impl true
  def handle_info({@initializing_scape_v1, %ScapeInit{scape_id: scape_id} = scape_init}, state) do
    :scapes_cache
    |> Cachex.put!(scape_id, scape_init)

    notify_cache_updated(@initializing_scape_v1, scape_init)

    {:noreply, state}
  end

  ####################### INITIALIZED SCAPE #######################
  @impl true
  def handle_info({@scape_initialized_v1, %ScapeInit{scape_id: scape_id} = scape_init}, state) do
    :scapes_cache
    |> Cachex.put!(scape_id, scape_init)

    notify_cache_updated(@scape_initialized_v1, scape_init)

    {:noreply, state}
  end

  ####################### DETACHED SCAPE #######################
  @impl true
  def handle_info({@scape_detached_v1, %ScapeInit{scape_id: scape_id} = scape_init}, state) do
    :scapes_cache
    |> Cachex.del!(scape_id)

    notify_cache_updated(@scape_detached_v1, scape_init)

    {:noreply, state}
  end

  ########################### SCAPE STARTED #######################
  @impl true
  def handle_info({@scape_started_v1, %ScapeInit{scape_id: scape_id} = scape_init}, state) do
    scape =
      case :scapes_cache
           |> Cachex.get!(scape_id) do
        {:ok, nil} ->
          scape_init

        {:ok, scape} ->
          scape

        {:error, _} ->
          scape_init
      end

    scape =
      %ScapeInit{
        scape
        | scape_status: @scape_started_status
      }

    case :scapes_cache
         |> Cachex.put!(scape_id, scape) do
      {:ok, _} ->
        Logger.info("Scape started: #{inspect(scape)}")
        notify_cache_updated(@scape_started_v1, scape_init)

      {:error, _} ->
        Logger.error("Failed to update Scape status to started: #{inspect(scape)}")
    end

    {:noreply, state}
  end

  ####################### UNHANDLED MESSAGES #######################
  @impl true
  def handle_info(msg, state) do
    Logger.warning("Scapes Service: Unhandled message => #{inspect(msg)}")
    {:noreply, state}
  end

  ####################### TERMINATE #######################
  @impl true
  def terminate(_reason, state) do
    {:ok, state}
  end

  ###################  PRIVATE  ###################
  defp notify_cache_updated(cause, scape_init) do
    Swai.PubSub
    |> PubSub.broadcast!(
      @scapes_cache_updated_v1,
      {cause, scape_init}
    )
  end

  ###################  PLUMBING  ###################

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def child_spec(_scape_init) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent
    }
  end
end
