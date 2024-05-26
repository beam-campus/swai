defmodule LogatronWeb.Dispatch.EdgeHandlerServer do
  use GenServer

  @moduledoc """
  The EdgeHandler is used to broadcast messages to all clients
  """

  alias Edge.Facts, as: EdgeFacts
  alias Phoenix.PubSub

  @edge_detached_v1 EdgeFacts.edge_detached_v1()
  @edge_attached_v1 EdgeFacts.edge_attached_v1()


  ################ API ################

  def pub_edge_attached(payload),
    do:
      GenServer.cast(
        __MODULE__,
        {:pub_edge_attached, payload}
      )

  def pub_edge_detached(payload),
    do:
      GenServer.cast(
        __MODULE__,
        {:pub_edge_detached, payload}
      )

  ################ CALLBACKS ################

  @impl true
  def handle_cast({:pub_edge_detached, payload}, state) do
    {:ok, edge_init} = Edge.Init.from_map(payload["edge_init"])

    PubSub.broadcast!(
      Logatron.PubSub,
      @edge_detached_v1,
      {@edge_detached_v1, edge_init}
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast({:pub_edge_attached, payload}, state) do
    {:ok, edge_init} = Edge.Init.from_map(payload["edge_init"])

    PubSub.broadcast!(
      Logatron.PubSub,
      @edge_attached_v1,
      {@edge_attached_v1, edge_init}
    )

    {:noreply, state}
  end


  @impl true
  def init(args) do
    {:ok, args}
  end

  ################# PLUMBING #################
  def start_link(args),
    do:
      GenServer.start_link(
        __MODULE__,
        args,
        name: __MODULE__
      )

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]},
      type: :worker,
      restart: :permanent
    }
  end
end
