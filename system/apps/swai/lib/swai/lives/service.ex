defmodule Lives.Service do
  use GenServer

  @moduledoc """
  Lives.Service contains the Cache for the Born2Died processes.
  """

  require Cachex
  require Logger

  alias Born2Died.Movement
  alias Phoenix.PubSub, as: PubSub
  alias Born2Died.Facts

  @initializing_life_v1 Facts.initializing_life_v1()
  @life_initialized_v1 Facts.life_initialized_v1()
  @life_detached_v1 Facts.life_detached_v1()
  @life_state_changed_v1 Facts.life_state_changed_v1()
  @life_moved_v1 Facts.life_moved_v1()

  @lives_cache_updated_v1 Facts.born2dieds_cache_updated_v1()

  ################### PUBLIC API ##################

  def get_all(),
    do:
      GenServer.call(
        __MODULE__,
        {:get_all}
      )

  def get_stream(),
    do:
      GenServer.call(
        __MODULE__,
        {:get_stream}
      )

  def count(),
    do:
      GenServer.call(
        __MODULE__,
        {:count}
      )

  def save(state),
    do:
      GenServer.cast(
        __MODULE__,
        {:save, state}
      )

  def delete(state),
    do:
      GenServer.cast(
        __MODULE__,
        {:delete, state}
      )

  def get_by_mng_farm_id(nil), do: []

  def get_by_mng_farm_id(mng_farm_id),
    do:
      GenServer.call(
        __MODULE__,
        {:get_by_mng_farm_id, mng_farm_id}
      )

  ################### CALLBACKS ###################

  @impl GenServer
  def init(opts) do
    Logger.info("Starting born2dieds cache")

    PubSub.subscribe(Swai.PubSub, @initializing_life_v1)
    PubSub.subscribe(Swai.PubSub, @life_detached_v1)
    PubSub.subscribe(Swai.PubSub, @life_state_changed_v1)
    PubSub.subscribe(Swai.PubSub, @life_initialized_v1)
    PubSub.subscribe(Swai.PubSub, @life_moved_v1)

    {:ok, opts}
  end

  ################### handle_cast ###################

  @impl GenServer
  def handle_cast({:save, life_init}, state) do
    Logger.debug("Saving life_init: #{inspect(life_init)}")

    # key = %{
    #   edge_id: life_init.edge_id,
    #   scape_id: life_init.scape_id,
    #   region_id: life_init.region_id,
    #   mng_farm_id: life_init.mng_farm_id,
    #   id: life_init.id
    # }

    key = life_init.id

    :lives_cache
    |> Cachex.put!(key, life_init)

    notify_cache_updated({@life_initialized_v1, life_init})
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:delete, life_init}, state) do
    :lives_cache
    |> Cachex.del!(life_init.id)

    notify_cache_updated({@life_detached_v1, life_init})
    {:noreply, state}
  end

  ################### handle_call ###################

  @impl GenServer
  def handle_call({:get_by_mng_farm_id, mng_farm_id}, _from, state) do
    {
      :reply,
      :lives_cache
      |> Cachex.stream!()
      |> Stream.filter(fn {:entry, _key, _nil, _internal_id, life_init} ->
        life_init.mng_farm_id == mng_farm_id
      end)
      |> Enum.map(fn {:entry, _key, _nil, _internal_id, life_init} -> life_init end),
      state
    }
  end

  @impl GenServer
  def handle_call({:get_all}, _from, state) do
    {
      :reply,
      :lives_cache
      |> Cachex.stream!()
      |> Enum.map(fn {:entry, _key, _nil, _internal_id, life_init} -> life_init end)
      |> Enum.sort_by(& &1.vitals.age)
      |> Enum.reverse(),
      state
    }
  end

  @impl GenServer
  def handle_call({:get_stream}, _from, state) do
    {
      :reply,
      :lives_cache
      |> Cachex.stream!(),
      state
    }
  end

  @impl GenServer
  def handle_call({:count}, _from, state) do
    {
      :reply,
      :lives_cache
      |> Cachex.size!(),
      state
    }
  end

  ################### handle_info ###################

  @impl GenServer
  def handle_info({@initializing_life_v1, life_init}, state) do
    save(life_init)
    notify_cache_updated({@initializing_life_v1, life_init})
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({@life_initialized_v1, life_init}, state) do
    :lives_cache
    |> Cachex.put!(life_init.id, life_init)

    notify_cache_updated({@life_initialized_v1, life_init})
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({@life_detached_v1, life_init}, state) do
    :lives_cache
    |> Cachex.del!(life_init.id)

    notify_cache_updated({@life_detached_v1, life_init})
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({@life_state_changed_v1, life_init}, state) do
    :lives_cache
    |> Cachex.put!(life_init.id, life_init)

    notify_cache_updated({@life_state_changed_v1, life_init})
    {:noreply, state}
  end

  def handle_info({@life_moved_v1, %Movement{} = movement}, state) do
    case :lives_cache
         |> Cachex.get_and_update(
           movement.born2died_id,
           fn life_init ->
             life_init
             |> Map.put(:pos, movement.to)
             |> Map.put(:status, "moving")
           end
         ) do
      {:commit, life_init} ->
        Logger.alert("Life position updated in cachex")
        notify_cache_updated({@life_moved_v1, life_init})
        {:noreply, state}

      _ ->
        Logger.error("Failed to update life position")
        {:noreply, state}
    end
  end

  ################### INTERNALS ###################
  defp notify_cache_updated(cause),
    do:
      PubSub.broadcast!(
        Swai.PubSub,
        @lives_cache_updated_v1,
        cause
      )

  #################### PLUMBING ####################
  def child_spec(opts),
    do: %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient
    }

  def start_link(opts),
    do:
      GenServer.start_link(
        __MODULE__,
        opts,
        name: __MODULE__
      )
end
