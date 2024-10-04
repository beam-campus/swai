defmodule SwaiAco.Macula.WebRtcPeer do
  @moduledoc """
  WebRTC peer
  """
  use GenServer

  alias Swai.Registry, as: EdgeRegistry
  alias Colors, as: Colors

  require Logger

  def start(%{edge_id: edge_id} = edge_init) do
    case start_link(edge_init) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        {:ok, pid}

      {:error, reason} ->
        Logger.error(
          "web_rtc_peer:#{edge_id} failed to start, reason: #{inspect(reason, pretty: true)}"
        )

        {:error, reason}
    end
  end

  ######### INIT #########
  @impl true
  def init(%{edge_id: edge_id} = edge_init) do
    Logger.info("#{__MODULE__} for [#{edge_id}] is UP => #{Colors.edge_theme(self())}")
    {:ok, edge_init}
  end

  ######## PLUMBING ########
  def to_name(key),
    do: "web_rtc_peer:#{key}"

  def via(key),
    do: EdgeRegistry.via_tuple({:web_rtc_peer, to_name(key)})

  def child_spec(%{edge_id: edge_id} = edge_init),
    do: %{
      id: to_name(edge_id),
      start: {__MODULE__, :start, [edge_init]},
      type: :worker,
      restart: :transient
    }

  def start_link(%{edge_id: edge_id} = edge_init),
    do:
      GenServer.start_link(
        __MODULE__,
        edge_init,
        name: via(edge_id)
      )
end
