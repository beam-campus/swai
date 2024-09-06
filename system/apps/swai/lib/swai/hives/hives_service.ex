defmodule Hives.Service do
  @moduledoc false
  use GenServer

  require Logger

  alias Swai.PubSub, as: SwaiPubSub
  alias Phoenix.PubSub, as: PubSub
  alias Hive.Facts, as: HiveFacts
  alias Hive.Init, as: HiveInit
  alias Schema.SwarmLicense, as: License

  @hive_facts HiveFacts.hive_facts()
  @hive_initialized_v1 HiveFacts.hive_initialized_v1()
  @hive_occupied_v1 HiveFacts.hive_occupied_v1()
  @hive_vacated_v1 HiveFacts.hive_vacated_v1()

  def get_candidates_for_license(%License{} = license) do
    :hives_cache
    |> Cachex.stream!()

    case :hives_cache |> Cachex.get!() do
      nil ->
        Logger.warning("Hive cache is empty")

      cache ->
        cache
        |> Map.values()
        |> Enum.filter(fn hive_init ->
          hive_init.hive_id == license.hive_id
        end)
    end
  end

  defp notify_hives_cache_updated(cause),
    do:
      SwaiPubSub
      |> PubSub.broadcast(@hive_facts, cause)

  ## Hive Vacated
  @impl true
  def handle_info(
        {@hive_vacated_v1, %HiveInit{hive_id: hive_id} = hive_init} = cause,
        state
      ) do
    case :hives_cache |> Cachex.get!(hive_id) do
      nil ->
        Logger.warning("Hive not found in cache: #{inspect(hive_init)}")

      _ ->
        :hives_cache
        |> Cachex.update!(hive_id, hive_init)
    end

    notify_hives_cache_updated(cause)

    {:noreply, state}
  end

  ## Hive Occupied
  @impl true
  def handle_info(
        {@hive_occupied_v1, %HiveInit{hive_id: hive_id} = hive_init} = cause,
        state
      ) do
    case :hives_cache |> Cachex.get!(hive_id) do
      nil ->
        Logger.warning("Hive not found in cache: #{inspect(hive_init)}")

      _ ->
        :hives_cache
        |> Cachex.update!(hive_id, hive_init)
    end

    notify_hives_cache_updated(cause)

    {:noreply, state}
  end

  ## Hive Initialized 
  @impl true
  def handle_info(
        {@hive_initialized_v1, %HiveInit{hive_id: hive_id} = hive_init} = cause,
        state
      ) do
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

  ## Falback function for unhandled messages

  @impl true
  def handle_info(msg, state) do
    Logger.warning("Unhandled Hive Fact: #{inspect(msg)}")
    {:noreply, state}
  end

  ##### PLUMBING #####
  @impl true
  def init(cache_file) do
    Logger.warning("Hives.Service is up =>  #{inspect(cache_file)}")

    SwaiPubSub
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
