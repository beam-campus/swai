defmodule Edge.System do
  @moduledoc """
  This module is responsible for handling the events that are emitted by the SwaiAco
  """
  use GenServer

  require Logger

  alias Swai.Registry, as: EdgeRegistry
  alias Edge.Hopes, as: EdgeHopes
  alias Scape.Init, as: ScapeInit
  alias Scape.System, as: ScapeSystem
  alias Edge.Init, as: EdgeInit
  alias Schema.SwarmLicense, as: License
  alias Edge.Emitter, as: EdgeEmitter

  @present_license_v1 EdgeHopes.present_license_v1()

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

  def present_license(%License{} = license),
    do:
      GenServer.cast(
        __MODULE__,
        {:present_license, license}
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

    Supervisor.start_link(
      [],
      name: via_sup(edge_id),
      strategy: :one_for_one
    )

    start_scapes(edge_init)

    EdgeEmitter.emit_edge_initialized(edge_init)
    {:ok, edge_init}
  end

  ################### HANDLE CALL ###################
  @impl true
  def handle_call(:get_scapes, _from, state) do
    scapes = Supervisor.which_children(EdgeServerSup)
    {:reply, scapes, state}
  end

  ##################### PROCESS MESSAGE - PRESENT LICENSE #####################
  @impl true
  def handle_cast(
        {:process_message, {_room, @present_license_v1, params}},
        %EdgeInit{} = state
      ) do
    case License.from_map(%License{}, params) do
      {:ok, license} ->
        license
        |> present_license()

      {:error, reason} ->
        Logger.error("Error queuing license: #{inspect(reason)}")
    end

    {:noreply, state}
  end

  ######################### PRESENT LICENSE ##############
  @impl true
  def handle_cast({:present_license, %License{} = license}, state) do
    Logger.info("EdgeServer.present_license: #{inspect(license)}")

    {:noreply, state}
  end

  ####################### START SCAPE #####################
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
    end

    {:noreply, state}
  end

  ##################### HANDLE CAST FALLBACK #####################
  @impl true
  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  ###################### HANDLE_INFO FALLBACK ######################
  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  ########################## PLUMBING ############################

  def via(key),
    do: EdgeRegistry.via_tuple({:edge_system, to_name(key)})

  def via_sup(key),
    do: EdgeRegistry.via_tuple({:edge_sup, to_name(key)})

  def to_name(key) when is_bitstring(key),
    do: "edge.system.#{key}"

  def child_spec(%EdgeInit{} = state) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [state]}
    }
  end

  def start_link(%EdgeInit{} = state) do
    GenServer.start_link(
      __MODULE__,
      state,
      name: __MODULE__
    )
  end
end
