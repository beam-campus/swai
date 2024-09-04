defmodule Hives.Service do
  @moduledoc false
  use GenServer

  require Logger

  alias Phoenix.PubSub, as: PubSub
  alias Hive.Facts, as: HiveFacts
  alias Hive.Init, as: HiveInit
  alias Swai.PubSub, as: SwaiPubSub

  @hive_facts HiveFacts.hive_facts()
  @hive_initialized_v1 HiveFacts.hive_initialized_v1()
  @hive_occupied_v1 HiveFacts.hive_occupied_v1()
  @hive_vacated_v1 HiveFacts.hive_vacated_v1()
  @hive_arena_initialized_v1 HiveFacts.hive_arena_initialized_v1()

  ## Hive Initialized 
  @impl true
  def handle_info({@hive_initialized_v1, %HiveInit{hive_id: hive_id} = hive_init}, state) do
    Logger.info("Hive Initialized: #{inspect(hive_init)}")

    case :hives_cache |> Cachex.get!(hive_id) do
      nil ->
        :hives_cache
        |> Cachex.put!(hive_id, hive_init)

      _ ->
        :hives_cache
        |> Cachex.update!(hive_id, hive_init)
    end

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
