defmodule Edge.System do
  @moduledoc """
  This module is responsible for handling the events that are emitted by the SwaiAco
  """
  use GenServer

  require Logger

  alias Swai.Registry, as: EdgeRegistry
  alias Scape.Init, as: ScapeInit
  alias Scape.System, as: ScapeSystem
  alias Edge.Init, as: EdgeInit
  alias Schema.SwarmLicense, as: License
  alias Edge.Emitter, as: EdgeEmitter
  alias Phoenix.PubSub, as: PubSub
  alias Edge.Facts, as: EdgeFacts

  @edge_facts EdgeFacts.edge_facts()
  @edge_attached_v1 EdgeFacts.edge_attached_v1()

  ##################### PUBLIC API #####################
  def start(%EdgeInit{} = edge_init) do
    case start_link(edge_init) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        {:ok, pid}

      {:error, reason} ->
        Logger.error("EdgeSystem failed to start, reason: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def process_message(room, {message, params}),
    do:
      GenServer.cast(
        __MODULE__,
        {:process_message, {room, message, params}}
      )

  def select_scape(scapes, %License{} = license),
    do:
      GenServer.cast(
        __MODULE__,
        {:select_scape, {scapes, license}}
      )

  def get_scapes(),
    do:
      GenServer.call(
        __MODULE__,
        :get_scapes
      )

  defp start_scapes(%EdgeInit{scapes_cap: scapes_cap}) do
    Enum.each(1..scapes_cap, fn scape_no ->
      GenServer.cast(
        __MODULE__,
        {:start_scape, scape_no}
      )
    end)
  end

  ##################### INIT ####################
  @impl true
  def init(%{edge_id: edge_id} = edge_init) do
    Process.flag(:trap_exit, true)

    #    EdgePubSub
    # |> PubSub.subscribe(@edge_facts)

    #    EdgeEmitter.emit_initializing_edge(edge_init)

    # start_scapes =
    #   Task.async(fn ->
    #     start_scapes(edge_init)
    #   end)
    #

    case Supervisor.start_link(
           [],
           name: via_sup(edge_id),
           strategy: :one_for_one
         ) do
      {:ok, pid} ->
        #        Task.await(start_scapes, 10_000)
        {:ok, pid}

      {:error, reason} ->
        Logger.error("Error starting edge system: #{inspect(reason)}")
        {:stop, reason}
    end

    # EdgeEmitter.emit_edge_initialized(edge_init)
    {:ok, edge_init}
  end

  ## GET_SCAPES
  @impl true
  def handle_call(:get_scapes, _from, %EdgeInit{edge_id: edge_id} = state) do
    scapes = Supervisor.which_children(via_sup(edge_id))
    {:reply, scapes, state}
  end

  ## CAST: Start Scape ############################
  @impl true
  def handle_cast({:start_scape, scape_no}, %EdgeInit{edge_id: edge_id} = state) do
    case ScapeInit.new(scape_no, state) do
      {:ok, scape_init} ->
        Supervisor.start_child(
          via_sup(edge_id),
          {ScapeSystem, scape_init}
        )

      {:error, reason} ->
        Logger.error("Error starting scape: #{inspect(reason)}")
        {:error, reason}
    end

    {:noreply, state}
  end

  ######### HANDLE CAST FALLBACK ###################
  @impl true
  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  ## Edge Attached ############################
  @impl true
  def handle_info({:edge_attached, %{edge_id: edge_id}}, state) do
    Logger.info("Edge attached: [#{edge_id}]")
    {:noreply, state}
  end

  ## HANDLE_INFO FALLBACK #################
  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  ## PLUMBING ############################
  def via(key),
    do: EdgeRegistry.via_tuple({:edge_system, to_name(key)})

  def via_sup(key),
    do: EdgeRegistry.via_tuple({:edge_sup, to_name(key)})

  def to_name(key) when is_bitstring(key),
    do: "edge.system:#{key}"

  def child_spec(%EdgeInit{} = state) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start, [state]},
      type: :supervisor,
      restart: :transient
    }
  end

  def start_link(%EdgeInit{} = edge_init) do
    GenServer.start_link(
      __MODULE__,
      edge_init,
      name: __MODULE__
    )
  end
end
