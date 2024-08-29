defmodule Edge.Server do
  @moduledoc """
  This module is responsible for handling the events that are emitted by the SwaiAco
  """
  use GenServer

  require Logger

  alias Edge.Hopes, as: EdgeHopes
  alias Scape.Init, as: ScapeInit
  alias Scape.System, as: ScapeSystem
  alias Edge.Init, as: EdgeInit

  @start_scape_v1 EdgeHopes.start_scape_v1()

  ##################### PUBLIC API #####################
  def process_message(room, {message, params}),
    do:
      GenServer.cast(
        __MODULE__,
        {:process_message, {room, message, params}}
      )

  def start_scape(%ScapeInit{} = scape),
    do:
      GenServer.cast(
        __MODULE__,
        {:start_scape, scape}
      )

  def stop_scape(%ScapeInit{} = scape),
    do:
      GenServer.cast(
        __MODULE__,
        {:stop_scape, scape}
      )

  def get_scapes(),
    do:
      GenServer.call(
        __MODULE__,
        :get_scapes
      )

  ################### HANDLE CALL ###################
  @impl true
  def handle_call(:get_scapes, _from, state) do
    scapes = Supervisor.which_children(EdgeServerSup)
    {:reply, scapes, state}
  end

  ##################### PROCESS MESSAGE #####################
  @impl true
  def handle_cast(
        {:process_message, {_room, @start_scape_v1, params}},
        %EdgeInit{} = state
      ) do
    case ScapeInit.from_map(%ScapeInit{}, params) do
      {:ok, scape} ->
        scape
        |> start_scape()

      {:error, reason} ->
        Logger.error("Error starting scape: #{inspect(reason)}")
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast({:process_message, {_room, _message, _params}}, state) do
    {:noreply, state}
  end

  ##################### START SCAPE #####################`
  @impl true
  def handle_cast({:start_scape, %ScapeInit{} = scape_init}, state) do

    scape_init = %ScapeInit{
      scape_init |
      edge_id: state.id,
      edge: state
    }

    Supervisor.start_child(
      EdgeServerSup,
      {ScapeSystem, scape_init}
    )

    {:noreply, state}
  end


  ##################### STOP SCAPE #####################
  @impl true
  def handle_cast({:stop_scape, %ScapeInit{} = scape_init}, state) do

    EdgeServerSup
    |> Supervisor.terminate_child(
      {ScapeSystem, scape_init}
    )

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

  ##################### INIT #####################
  @impl true
  def init(%EdgeInit{} = state) do
    Supervisor.start_link(
      [],
      name: EdgeServerSup,
      strategy: :one_for_one
    )

    {:ok, state}
  end

  ########################## PLUMBING ############################
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
