# Credits: Special thanks to @cmo and @al2o3cr for the help on this one.

defmodule Edges.Service do
  use GenServer

  @moduledoc """
  The Cache module is used to store and retrieve data from the Edges ETS cache.
  """

  alias Edge.Facts, as: EdgeFacts
  alias Phoenix.PubSub
  alias Edge.Init, as: EdgeInit

  require Logger

  @edges_cache_updated_v1 EdgeFacts.edges_cache_updated_v1()
  @edge_attached_v1 EdgeFacts.edge_attached_v1()
  @edge_detached_v1 EdgeFacts.edge_detached_v1()

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

  def get_stats(),
    do:
      GenServer.call(
        __MODULE__,
        :get_stats
      )

  def get_edge_stats(edge_id),
    do:
      GenServer.call(
        __MODULE__,
        {:get_edge_stats, edge_id}
      )

  def get_by_id(id),
    do:
      GenServer.call(
        __MODULE__,
        {:get_by_id, id}
      )

  ############## CALLBACKS #########
  @impl GenServer
  def handle_call(:count, _from, state),
    do:
      {:reply,
       :edges_cache
       |> Cachex.size!(), state}

  @impl GenServer
  def handle_call(:get_all, _from, state),
    do:
      {:reply,
       :edges_cache
       |> Cachex.stream!()
       |> Enum.map(fn {:entry, _key, _nil, _internal_key, edge} -> edge end), state}

  @impl GenServer
  def handle_call({:get_by_id, id}, _from, state),
    do:
      {:reply,
       :edges_cache
       |> Cachex.get!(id)
       |> Enum.map(& &1), state}

  @impl GenServer
  def handle_call(:get_stats, _from, state),
    do:
      {:reply,
       :edges_cache
       |> Cachex.stats!(), state}

  @impl GenServer
  def handle_call({:get_edge_stats, edge_id}, _from, state) do
    case   :edges_cache
      |> Cachex.get!(edge_id) do
        {:ok, nil} ->
          {:error, "Edge not found"}

        {:ok, edge} ->
          num_of_sc =
            :edges_cache
            |> Cachex.stream!()
            |> Enum.filter(fn {:entry, _, _, _, edge} -> edge.id == edge_id end)

          {:reply, %{edge: edge, num_of_sc: num_of_sc}, state}
      end
  end

  ################### handle_info ###################
  @impl GenServer
  def handle_info({@edge_attached_v1, edge_init}, state) do
    :edges_cache
    |> Cachex.put!(edge_init.id, edge_init)

    notify_edges_updated({@edge_attached_v1, edge_init})
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({@edge_detached_v1, edge_init}, state) do
    :edges_cache
    |> Cachex.del!(edge_init.id)

    notify_edges_updated({@edge_detached_v1, edge_init})
    {:noreply, state}
  end

  @impl GenServer
  def init(args \\ []) do
    # :edges_cache
    # |> Cachex.start()

    PubSub.subscribe(Swai.PubSub, @edge_attached_v1)
    PubSub.subscribe(Swai.PubSub, @edge_detached_v1)
    {:ok, args}
  end

  ############ INTERNALS ########
  defp notify_edges_updated(cause),
    do:
      PubSub.broadcast!(
        Swai.PubSub,
        @edges_cache_updated_v1,
        cause
      )

  ########### PLUMBING ##########

  def child_spec(),
    do: %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent
    }

  def start_link(_args),
    do:
      GenServer.start_link(
        __MODULE__,
        nil,
        name: __MODULE__
      )
end
