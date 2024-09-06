defmodule Edge.Client do
  use Slipstream

  @moduledoc """
  Edge.Client is the client-side of the SwaiEdge.Socket server.
  It is part of the main application supervision tree.
  """
  require Logger

  alias Edge.Facts, as: EdgeFacts
  # alias Edge.Hopes, as: EdgeHopes
  alias Swai.Registry, as: EdgeRegistry
  alias Edge.System, as: EdgeServer
  alias Edge.Init, as: EdgeInit
  alias Edge.PubSub, as: EdgePubSub
  alias Phoenix.PubSub, as: PubSub

  @edge_lobby "edge:lobby"
  @edge_attached_v1 EdgeFacts.edge_attached_v1()
  @presence_changed_v1 EdgeFacts.presence_changed_v1()
  @edge_facts EdgeFacts.edge_facts()

  # @socket_reconnect_delay 1_000

  # @joined_edge_lobby "edge:lobby:joined"

  ############# API ################
  def publish(edge_id, event, payload) do
    Logger.warning("Edge.Client publish:  #{inspect(event)}")

    GenServer.cast(
      via(edge_id),
      {:publish, @edge_lobby, event, payload}
    )
  end

  def request(edge_id, hope, payload) do
    Logger.warning("Edge.Client request:  #{inspect(hope)}")

    GenServer.call(
      via(edge_id),
      {:request, @edge_lobby, hope, payload}
    )
  end

  ############# CALLBACKS ################
  @impl Slipstream
  def handle_call({:request, topic, hope, payload}, _from, socket) do
    Logger.warning("Edge.Client request:  #{inspect(hope)}")

    {:ok, push_ref} =
      socket
      |> push!(topic, hope, payload)

    resp =
      push_ref
      |> await_reply!(1_000)

    {:reply, resp, socket}
  end

  @impl Slipstream
  def handle_cast({:publish, topic, event, payload}, socket) do
    socket
    |> push!(topic, event, payload)

    {:noreply, socket}
  end

  @impl Slipstream
  def init(
        %{
          edge_init: %{
            edge_id: edge_id,
            scapes_cap: scapes_cap,
            hives_cap: hives_cap
          }
        } = args
      ) do
    {:ok, socket} =
      new_socket()
      |> assign(:edge_init, args.edge_init)
      |> assign(:config, args.config)
      |> connect(args.config)

    Logger.warning("Edge.Client init: #{inspect(socket)}")

    Logger.info(
      "Edge.Client is up: edge_id #{edge_id}, scapes_cap #{scapes_cap}, hives_cap #{hives_cap}"
    )

    {:ok, socket, {:continue, :start_ping}}
  end

  @impl Slipstream
  def handle_connect(socket) do
    edge_init = socket.assigns.edge_init

    joined_socket =
      socket
      |> join(@edge_lobby, edge_init)

    {:ok, joined_socket}
  end

  @impl Slipstream
  def handle_join(@edge_lobby, join_response, socket) do
    Logger.debug("Edge.Client handle join: #{@edge_lobby} #{inspect(join_response)}")

    # socket
    # |> push(@edge_lobby, @edge_attached_v1, %{edge_init: socket.assigns.edge_init})

    Process.send_after(self(), {:after_join, join_response}, 1_000)
    {:ok, socket}
  end

  @impl Slipstream
  def handle_disconnect(reason, socket) do
    Logger.warning("Edge.Client disconnected: #{inspect(reason)}")

    case reconnect(socket) do
      {:ok, socket} -> {:ok, socket}
      {:error, reason} -> {:stop, reason, socket}
    end
  end

  @impl Slipstream
  def handle_continue(:start_ping, socket) do
    {:noreply, socket}
  end

  @impl Slipstream
  def handle_info({:after_join, something}, socket) do
    Logger.debug("Edge.Client received: :after_join #{inspect(something)}")

    edge_init = socket.assigns.edge_init

    # socket
    # |> push!(@edge_lobby, @edge_attached_v1, %{edge_init: edge_init})
    #
    # EdgePubSub
    # |> PubSub.broadcast(
    #   @edge_facts,
    #   {@edge_attached_v1, edge_init}
    # )

    {:noreply, socket}
  end

  @impl Slipstream
  def handle_info({@presence_changed_v1, presence_list}, socket) do
    Logger.debug("Edge.Client received: [#{@presence_changed_v1}] \n #{inspect(presence_list)}")
    {:noreply, socket}
  end

  @impl Slipstream
  def handle_info(_msg, socket) do
    # Logger.debug("Edge.Client received: #{inspect(msg)}")
    {:noreply, socket}
  end

  @impl Slipstream
  def handle_message(room, message, params, socket) do
    # Logger.warning("Edge.Client received:
    # room: #{inspect(room)}
    # msg: #{inspect(message)}
    # params: #{inspect(params)}")

    EdgeServer.process_message(room, {message, params})

    {:ok, socket}
  end

  ############ PLUMBING ################
  def to_name(edge_id),
    do: "edge.client:#{edge_id}"

  def to_topic(edge_id),
    do: "edge:lobby:#{edge_id}"

  def via(edge_id),
    do: EdgeRegistry.via_tuple({:client, to_name(edge_id)})

  def child_spec(%EdgeInit{edge_id: edge_id} = edge_init) do
    config = Application.fetch_env!(:swai_edge, __MODULE__)

    %{
      id: to_name(edge_id),
      start: {__MODULE__, :start_link, [%{config: config, edge_init: edge_init}]},
      restart: :transient,
      type: :worker
    }
  end

  def start_link(%{edge_init: %EdgeInit{edge_id: edge_id}} = args),
    do:
      Slipstream.start_link(
        __MODULE__,
        args,
        name: via(edge_id)
      )
end
