defmodule Arenas.Service do
  @moduledoc false
  use GenServer

  require Logger

  alias Arena.Facts, as: ArenaFacts
  alias Arena.Init, as: ArenaInit
  alias Arena.Status, as: ArenaStatus
  alias Phoenix.PubSub, as: PubSub
  alias Schema.SwarmLicense, as: License

  @arena_facts ArenaFacts.arena_facts()
  @arenas_cache_facts ArenaFacts.arenas_cache_facts()
  @arena_initialized_v1 ArenaFacts.arena_initialized_v1()
  @arena_status_initialized ArenaStatus.initialized()

  ## Public API
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

  def start(cache_file) do
    case start_link(cache_file) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        {:ok, pid}
    end
  end

  ## INIT
  @impl GenServer
  def init(cache_file) do
    Process.flag(:trap_exit, true)

    Swai.PubSub
    |> PubSub.subscribe(@arena_facts)

    {:ok, cache_file}
  end

  ## API CALLS

  ####################### HYDRATE #######################

  @impl GenServer
  def handle_call({:hydrate, %{scape_id: nil} = license}, _from, cache_file) do
    the_arena = ArenaInit.default()
    new_license = %License{license | arena: the_arena}
    {:reply, new_license, cache_file}
  end

  @impl GenServer
  def handle_call({:hydrate, %{scape_id: scape_id} = license}, _from, cache_file) do
    the_arena =
      case :arenas_cache |> Cachex.get(scape_id) do
        {:ok, nil} ->
          ArenaInit.default()

        {:ok, arena_init} ->
          arena_init

        _ ->
          ArenaInit.default()
      end

    new_license = %License{license | arena: the_arena}

    {:reply, new_license, cache_file}
  end

  ####################### GET ALL #######################
  @impl GenServer
  def handle_call(:get_all, _from, cache_file) do
    reply =
      :arenas_cache
      |> Cachex.stream!()
      |> Stream.map(fn {:entry, _, _, _, arena} -> arena end)
      |> Enum.to_list()

    {:reply, reply, cache_file}
  end

  ####################### SUBSCRIBED FACTS ################
  @impl GenServer
  def handle_info(
        {@arena_initialized_v1,
         %Arena.Init{
           arena_id: arena_id
         } = arena_init} = cause,
        state
      ) do
    new_arena =
      case :arenas_cache |> Cachex.get!(arena_id) do
        nil ->
          arena_init

        arena ->
          arena
      end

    new_arena =
      %ArenaInit{new_arena | arena_status: @arena_status_initialized}

    :arenas_cache
    |> Cachex.put!(arena_id, new_arena)

    notify_cache_updated(cause)

    {:noreply, state}
  end

  ## FALLTHROUGHS
  @impl GenServer
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp notify_cache_updated(cause) do
    Swai.PubSub
    |> PubSub.broadcast!(
      @arenas_cache_facts,
      {:arena, cause}
    )
  end

  ## plumbing
  # def to_name(key),
  #   do: "arenas.service.#{key}"
  #
  # def via(scape_id),
  #   do: SwaiRegistry.via_tuple({:arenas, to_name(scape_id)})
  #
  defp start_link(cache_file),
    do:
      GenServer.start_link(
        __MODULE__,
        cache_file,
        name: __MODULE__
      )

  def child_spec(cache_file),
    do: %{
      id: __MODULE__,
      start: {__MODULE__, :start, [cache_file]},
      type: :supervisor,
      restart: :transient
    }
end
