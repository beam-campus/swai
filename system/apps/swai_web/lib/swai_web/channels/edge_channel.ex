defmodule SwaiWeb.EdgeChannel do
  use SwaiWeb, :channel

  @moduledoc """
  The EdgeChannel is used to broadcast messages to all clients
  """
  require Logger
  require Phoenix.PubSub

  alias Schema.SwarmLicense
  alias SwaiWeb.EdgePresence, as: EdgePresence
  alias SwaiWeb.EdgeDispatcher, as: EdgeDispatcher

  alias SwaiWeb.ScapeDispatcher, as: ScapeDispatcher
  alias SwaiWeb.Dispatch.ChannelWatcher
  alias SwaiWeb.HiveDispatcher, as: HiveDispatcher

  alias Edge.Facts, as: EdgeFacts
  alias Edge.Hopes, as: EdgeHopes

  alias Scape.Facts, as: ScapeFacts
  alias Hive.Facts, as: HiveFacts

  alias Edge.Init, as: EdgeInit
  alias Scape.Init, as: ScapeInit
  alias Schema.SwarmLicense, as: SwarmLicense

  @hope_shout "hope:shout"
  @hope_ping "ping"
  @hope_join_edge "join_edge"

  # @scape_attached_v1 Facts.scape_attached_v1()
  @edge_attached_v1 EdgeFacts.edge_attached_v1()

  @start_scape_v1 EdgeHopes.start_scape_v1()
  @present_license_v1 EdgeHopes.present_license_v1()

  @initializing_scape_v1 ScapeFacts.initializing_scape_v1()
  @scape_initialized_v1 ScapeFacts.scape_initialized_v1()
  @scape_started_v1 ScapeFacts.scape_started_v1()
  @scape_detached_v1 ScapeFacts.scape_detached_v1()

  @hive_initialized_v1 HiveFacts.hive_initialized_v1()
  @hive_occupied_v1 HiveFacts.hive_occupied_v1()
  @hive_vacated_v1 HiveFacts.hive_vacated_v1()
  @hive_arena_initialized_v1 HiveFacts.hive_arena_initialized_v1()

  @presence_changed_v1 EdgeFacts.presence_changed_v1()
  @edge_lobby "edge:lobby"

  def queue_license(%EdgeInit{socket: edge_socket}, %SwarmLicense{} = license) do
    Logger.info("EdgeChannel.present_license: #{inspect(license)}")

    edge_socket
    |> push(@present_license_v1, license)
  end

  ################ CALLBACKS ################
  @impl true
  def join(@edge_lobby, edge_init, socket) do
    send(self(), {:after_join, edge_init})

    ChannelWatcher.monitor(
      @edge_lobby,
      self(),
      {EdgeDispatcher, :pub_edge_detached, [%{"edge_init" => edge_init}]}
    )

    {:ok, socket}
  end

  ####################### AFTER JOIN #######################
  @impl true
  def handle_info({:after_join, %{"edge_id" => edge_id}}, socket) do
    Logger.info(":after_join #{inspect(socket)}")

    {:ok, _} =
      socket
      |> EdgePresence.track(edge_id, %{
        online_at: inspect(System.system_time(:second))
      })

    socket
    |> broadcast(@presence_changed_v1, EdgePresence.list(socket))

    {:noreply, socket}
  end

  ########################## IN HELLO ############################
  @impl true
  def handle_in("hello", payload, socket) do
    socket
    |> broadcast!("hello", payload)

    {:reply, {:ok, payload}, socket}
  end

  ############################# IN PING ############################
  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in(@hope_ping, payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  ########################## IN JOIN EDGE ############################
  @impl true
  def handle_in(@hope_join_edge, payload, socket) do
    socket
    |> broadcast!(@hope_shout, payload)

    {:noreply, socket}
  end

  ############################# IN SHOUT ############################
  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (farm:lobby).
  @impl true
  def handle_in(@hope_shout, payload, socket) do
    socket
    |> broadcast!(@hope_shout, payload)

    {:noreply, socket}
  end

  #################### IN EDGE ATTACHED ###########################
  @impl true
  def handle_in(@edge_attached_v1, payload, socket) do
    EdgeDispatcher.pub_edge_attached(payload, socket)
    {:noreply, socket}
  end

  ################### IN INITIALIZING SCAPE #######################
  @impl true
  def handle_in(@initializing_scape_v1, payload, socket) do
    ScapeDispatcher.pub_initializing_scape(payload, socket)
    {:noreply, socket}
  end

  ##################### IN SCAPE INITIALIZED #######################
  @impl true
  def handle_in(@scape_initialized_v1, payload, socket) do
    ScapeDispatcher.pub_scape_initialized(payload, socket)
    {:noreply, socket}
  end

  #################### IN SCAPE STARTED ###########################
  @impl true
  def handle_in(@scape_started_v1, payload, socket) do
    ScapeDispatcher.pub_scape_started(payload, socket)
    {:noreply, socket}
  end

  ##################### IN SCAPE DETACHED ##########################
  @impl true
  def handle_in(@scape_detached_v1, payload, socket) do
    ScapeDispatcher.pub_scape_detached(payload, socket)
    {:noreply, socket}
  end

  ##################### IN HIVE INITIALIZED ########################
  @impl true
  def handle_in(@hive_initialized_v1, payload, socket) do
    HiveDispatcher.pub_hive_initialized(payload, socket)
    {:noreply, socket}
  end

  #################### IN HIVE OCCUPIED ###########################
  @impl true
  def handle_in(@hive_occupied_v1, payload, socket) do
    HiveDispatcher.pub_hive_occupied(payload, socket)
    {:noreply, socket}
  end

  ################### HIVE VACATED ###############################
  @impl true
  def handle_in(@hive_vacated_v1, payload, socket) do
    HiveDispatcher.pub_hive_vacated(payload, socket)
    {:noreply, socket}
  end

  ########## IN HIVE ARENA INITIALIZED ##########################
  @impl true
  def handle_in(@hive_arena_initialized_v1, payload, socket) do
    HiveDispatcher.pub_hive_arena_initialized(payload, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_in(_, payload, socket) do
    Logger.info("EdgeChannel.handle_in: #{inspect(payload)}")
    {:noreply, socket}
  end

  # ################ INTERNALS ################
  # defp to_topic(edge_id),
  #   do: "edge:lobby:#{edge_id}"
end
