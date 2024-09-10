defmodule Arenas.Service do
  @moduledoc false
  use GenServer

  require Logger

  alias Arena.Facts, as: ArenaFacts
  alias Phoenix.PubSub, as: PubSub
  alias Arena.Init, as: ArenaInit

  @arena_facts ArenaFacts.arena_facts()
  @arena_cache_updated_v1 ArenaFacts.arena_cache_updated_v1()
  @arena_initialized_v1 ArenaFacts.arena_initialized_v1()

  ## Public API
  def get_all(),
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
  @impl GenServer
  def handle_call(:get_all, _from, cache_file) do
    reply =
      :arenas_cache
      |> Cachex.stream!()
      |> Stream.map(fn {:entry, _, _, _, arena} -> arena end)
      |> Enum.to_list()

    {:reply, reply, cache_file}
  end

  ## SUBSCRIBED FACTS
  @impl GenServer
  def handle_info(
        {@arena_initialized_v1,
         %Arena.Init{
           arena_id: arena_id
         } = arena_init} = cause,
        state
      ) do
    case :arenas_cache |> Cachex.get!(arena_id) do
      nil ->
        :arenas_cache
        |> Cachex.put!(arena_id, arena_init)

      _ ->
        :arenas_cache
        |> Cachex.update!(arena_id, arena_init)
    end

    notify_cache_updated(cause, arena_init)

    {:noreply, state}
  end

  ## FALLTHROUGHS
  @impl GenServer
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp notify_cache_updated(cause, arena_init) do
    Swai.PubSub
    |> PubSub.broadcast!(
      @arena_cache_updated_v1,
      {cause, arena_init}
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
