defmodule Hives.Service do
  @moduledoc false
  use GenServer

  require Logger
  import Flags

  alias Hive.Facts, as: HiveFacts
  alias Hive.Init, as: HiveInit
  alias Hive.Status, as: HiveStatus
  alias Phoenix.PubSub, as: PubSub
  alias Schema.SwarmLicense, as: License

  @hive_facts HiveFacts.hive_facts()
  @hive_initialized_v1 HiveFacts.hive_initialized_v1()
  @hive_occupied_v1 HiveFacts.hive_occupied_v1()
  @hive_vacated_v1 HiveFacts.hive_vacated_v1()

  def hydrate(license),
    do:
      GenServer.call(
        __MODULE__,
        {:hydrate, license}
      )

  def get_all,
    do:
      GenServer.call(
        __MODULE__,
        :get_all
      )

  defp notify_hives_cache_updated(cause),
    do:
      Swai.PubSub
      |> PubSub.broadcast(@hive_facts, cause)

  ## Handle get_all
  @impl true
  def handle_call(:get_all, _from, state) do
    reply =
      :hives_cache
      |> Cachex.stream!()
      |> Stream.map(fn {:entry, _id, _internal, _nil, hive_init} -> hive_init end)
      |> Enum.to_list()

    {:reply, reply, state}
  end

  ############### CALL HYDRATE ############################
  @impl true
  def handle_call({:hydrate, %{hive_id: nil} = license}, _from, state) do
    the_hive = HiveInit.default()
   new_license = %License{license |
      hive_id: the_hive.hive_id,
      hive: the_hive
    }
    {:reply, new_license, state}
  end

  @impl true
  def handle_call({:hydrate, %{hive_id: hive_id} = license}, _from, state) do
    the_hive =
      case :hives_cache |> Cachex.get(hive_id) do
        {:ok, nil} ->
          HiveInit.default()

        {:ok, old} ->
          old

        _ ->
          HiveInit.default()
      end

    new_license = %License{license | hive: the_hive}
    {:reply, new_license, state}
  end

  defp hive_from_map(seed, %HiveInit{} = hive_init) do
    case HiveInit.from_map(seed, hive_init) do
      {:ok, result} ->
        result

      {:error, changeset} ->
        Logger.error("invalid Hive Map, reason: #{inspect(changeset)}")
        seed
    end
  end

  ################# HIVE VACATED ########################
  @impl true
  def handle_info(
        {@hive_vacated_v1, %HiveInit{hive_id: hive_id} = hive_init} = cause,
        state
      ) do
    case :hives_cache |> Cachex.get!(hive_id) do
      nil ->
        :hives_cache
        |> Cachex.put!(hive_id, hive_init)

      found_hive ->
        hive_init =
          %HiveInit{
            found_hive
            | hive_status:
                found_hive.hive_status
                |> unset(HiveStatus.hive_occupied())
                |> set(HiveStatus.hive_vacant())
          }

        :hives_cache
        |> Cachex.update!(hive_id, hive_init)
    end

    notify_hives_cache_updated(cause)

    {:noreply, state}
  end

  ################# HIVE OCCUPIED ########################
  @impl true
  def handle_info(
        {@hive_occupied_v1, %HiveInit{hive_id: hive_id} = hive_init} = cause,
        state
      ) do
    case :hives_cache |> Cachex.get!(hive_id) do
      nil ->
        :hives_cache
        |> Cachex.put!(hive_id, hive_init)

      seed ->
        new_hive = %HiveInit{
          hive_from_map(seed, hive_init)
          | hive_status:
              seed.hive_status
              |> unset(HiveStatus.hive_vacant())
              |> set(HiveStatus.hive_occupied())
        }

        :hives_cache
        |> Cachex.update!(hive_id, new_hive)

        notify_hives_cache_updated(cause)
    end

    {:noreply, state}
  end

  ################# HIVE INITIALIZED ########################
  @impl true
  def handle_info(
        {@hive_initialized_v1, %HiveInit{hive_id: hive_id} = hive_init} = cause,
        state
      ) do
    hive_init =
      %HiveInit{
        hive_init
        | hive_status: HiveStatus.hive_initialized()
      }

    case :hives_cache |> Cachex.get!(hive_id) do
      nil ->
        :hives_cache
        |> Cachex.put!(hive_id, hive_init)

      _ ->
        :hives_cache
        |> Cachex.update!(hive_id, hive_init)
    end

    notify_hives_cache_updated(cause)

    {:noreply, state}
  end

  ########################### FALLTHROUGHS #########################
  ## Handle Info Fallthrough
  @impl true
  def handle_info(msg, state) do
    Logger.warning("Unhandled Hive Fact: #{inspect(msg)}")
    {:noreply, state}
  end

  ######################### PLUMBING ################################
  @impl true
  def init(cache_file) do
    Logger.warning("Hives.Service is up =>  #{inspect(cache_file)}")

    Swai.PubSub
    |> PubSub.subscribe(@hive_facts)

    {:ok, cache_file}
  end

  def start(cache_file) do
    case start_link(cache_file) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        {:ok, pid}

      {:error, reason} ->
        Logger.error("Hives.Service failed to start: #{inspect(reason)}")
    end
  end

  def start_link(cache_file) do
    GenServer.start_link(
      __MODULE__,
      cache_file,
      name: __MODULE__
    )
  end

  def child_spec(cache_file),
    do: %{
      id: __MODULE__,
      start: {__MODULE__, :start, [cache_file]},
      type: :worker,
      restart: :permanent
    }
end
