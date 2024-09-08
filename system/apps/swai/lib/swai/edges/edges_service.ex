# Credits: Special thanks to @cmo and @al2o3cr for the help on this one.

defmodule Edges.Service do
  use GenServer

  @moduledoc """
  The Cache module is used to store and retrieve data from the Edges ETS cache.
  """

  alias Edge.Facts, as: EdgeFacts
  alias Phoenix.PubSub, as: PubSub
  alias Edge.Init, as: EdgeInit
  alias Schema.EdgeStats, as: EdgeStats

  require Colors
  require Logger

  @edge_facts EdgeFacts.edge_facts()

  @edges_cache_updated_v1 EdgeFacts.edges_cache_updated_v1()
  @edge_attached_v1 EdgeFacts.edge_attached_v1()
  @edge_detached_v1 EdgeFacts.edge_detached_v1()

  def count(),
    do:
      GenServer.call(
        __MODULE__,
        :count
      )

  def get_candidates_for_biotope(biotope_id),
    do:
      GenServer.call(
        __MODULE__,
        {:get_candidates_for_biotope, biotope_id}
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

  def get_by_biotope_id(biotope_id),
    do:
      :edges_cache
      |> Cachex.stream!()
      |> Stream.filter(fn {:entry, _, _, _, edge} -> edge.biotope_id == biotope_id end)
      |> Enum.to_list()

  defp get_edge(%{edge_id: edge_id} = _edge_init) do
    case :edges_cache
         |> Cachex.get!(edge_id) do
      nil ->
        nil

      edge ->
        edge

      msg ->
        Logger.alert("get_edge: unknown message: #{inspect(msg)}")
    end
  end

  defp get_by_ip(%EdgeInit{ip_address: queried_address}),
    do:
      :edges_cache
      |> Cachex.stream!()
      |> Enum.find(fn {:entry, _, _, _, %EdgeInit{ip_address: candidate_address}} ->
        candidate_address == queried_address
      end)

  defp get_by_id(%EdgeInit{edge_id: queried_id}),
    do:
      :edges_cache
      |> Cachex.stream!()
      |> Enum.find(fn {:entry, _, _, _, %EdgeInit{edge_id: candidate_id}} ->
        candidate_id == queried_id
      end)

  ############## CALLBACKS #########
  @impl GenServer
  def init(args \\ []) do
    Logger.warning("Edges.Service is up => #{Colors.edge_theme(self())}")

    Swai.PubSub
    |> PubSub.subscribe(@edge_facts)

    {:ok, args}
  end

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
  def handle_call({:get_by_id, edge_id}, _from, state) do
    case :edges_cache
         |> Cachex.get!(edge_id) do
      {:ok, nil} ->
        {:reply, nil, state}

      {:ok, edge} ->
        {:reply, edge, state}
    end
  end

  @impl GenServer
  def handle_call(:get_stats, _from, state),
    do:
      {:reply,
       :edges_cache
       |> Cachex.stats!(), state}

  def handle_call({:get_candidates_for_biotope, biotope_id}, _from, state),
    do: {
      :reply,
      :edges_cache
      |> Cachex.stream!()
      |> Stream.filter(fn {:entry, _, _, _, edge} -> edge.biotope_id == biotope_id end)
      |> Stream.map(fn {:entry, _, _, _, edge} -> edge end)
      |> Enum.to_list(),
      state
    }

  @impl GenServer
  def handle_call({:get_edge_stats, edge_id}, _from, state) do
    case :edges_cache
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

  # edge_attached ###################
  @impl GenServer
  def handle_info({@edge_attached_v1, %EdgeInit{edge_id: edge_id} = edge_init}, _state) do
    state =
      case get_edge(edge_init) do
        nil ->
          new_edge = %EdgeInit{
            edge_init
            | stats: %EdgeStats{
                nbr_of_agents: 1
              }
          }

          :edges_cache
          |> Cachex.put!(edge_id, new_edge)

        old ->
          %{stats: %EdgeStats{} = old_stats} = old

          new_stats = %EdgeStats{
            old_stats
            | nbr_of_agents: old_stats.nbr_of_agents + 1
          }

          new_edge = %EdgeInit{
            old
            | stats: new_stats
          }

          :edges_cache
          |> Cachex.update!(edge_id, new_edge)
      end

    notify_edges_updated({@edge_attached_v1, edge_init})
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({@edge_detached_v1, %EdgeInit{} = edge_init}, _state) do
    ######################################################################
    ## @edge_detached_v1 does not remove the edge entry from the cache
    # it only decrements the number of agents on the edge.
    ## If the number of agents on the edge is 0, the edge is removed from the cache.
    ######################################################################
    # Logger.debug("Edge detached: #{inspect(edge_init)}")
    state =
      case get_by_id(%{edge_id: edge_id} = edge_init) do
        nil ->
          "nothing to detach"

        {:entry, _, _, _, old_edge} ->
          %{stats: %EdgeStats{} = old_stats} = old_edge

          new_stats = %EdgeStats{
            old_stats
            | nbr_of_agents: old_stats.nbr_of_agents - 1
          }

          %EdgeInit{} =
            new_edge = %EdgeInit{
              old_edge
              | stats: new_stats
            }

          :edges_cache
          |> Cachex.update!(edge_id, new_edge)

          notify_edges_updated({@edge_detached_v1, new_edge})

          if new_edge.stats.nbr_of_agents == 0 do
            Process.send_after(self(), {:remove_edge, new_edge}, 10_000)
          end

          "edge node [#{edge_id}] detached"
      end

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:remove_edge, %EdgeInit{edge_id: edge_id} = edge_init}, _state) do
    state =
      :edges_cache
      |> Cachex.del!(edge_id)

    notify_edges_updated({:remove_edge, edge_init})
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(_msg, state), do: {:noreply, state}

  ############ INTERNALS ########
  defp notify_edges_updated(cause),
    do:
      Swai.PubSub
      |> PubSub.broadcast!(
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
