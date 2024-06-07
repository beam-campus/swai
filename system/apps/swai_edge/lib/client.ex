defmodule Edge.Client do
  use Slipstream

  @moduledoc """
  Edge.Client is the client-side of the SwaiEdge.Socket server.
  It is part of the main application supervision tree.
  """
  require Logger

  alias Edge.Facts, as: EdgeFacts

  @edge_lobby "edge:lobby"
  @edge_attached_v1 EdgeFacts.edge_attached_v1()
  @presence_changed_v1 EdgeFacts.presence_changed_v1()
  # @joined_edge_lobby "edge:lobby:joined"

  ############# API ################
  def publish(edge_id, event, payload),
    do:
      GenServer.cast(
        via(edge_id),
        {:publish, @edge_lobby, event, payload}
      )

  ############# CALLBACKS ################
  @impl Slipstream
  def handle_cast({:publish, topic, event, payload}, socket) do
    # Logger.debug(":publish :\n event => #{inspect(event)}\n payload => #{inspect(payload)}")

    _res =
      socket
      |> push(topic, event, payload)

    # Logger.debug("#{inspect(event)} => #{inspect(res)}")
    {:noreply, socket}
  end

  @impl Slipstream
  def init(args) do
    Logger.alert("Edge.Client init: #{inspect(args)}")

    socket =
      new_socket()
      |> assign(:edge_init, args.edge_init)
      |> connect!(args.config)

    {:ok, socket, {:continue, :start_ping}}
  end

  @impl Slipstream
  def handle_connect(socket) do
    join_result = join(socket, @edge_lobby, socket.assigns.edge_init)
    Logger.alert("Edge.Client handle_connect: #{inspect(join_result)}")
    {:ok, join_result}
  end

  @impl Slipstream
  def handle_join(@edge_lobby, join_response, socket) do
    Logger.alert("Edge.Client handle_join: #{@edge_lobby} #{inspect(join_response)}")
    push(socket, @edge_lobby, @edge_attached_v1, %{edge_init: socket.assigns.edge_init})
    Process.send_after(self(), {:after_join, join_response}, 1000)
    # {:noreply, socket}
    {:ok, socket}
  end

  @impl Slipstream
  def handle_disconnect(_reason, socket) do
    {:stop, :normal, socket}
  end

  @impl Slipstream
  def handle_continue(:start_ping, socket) do
    {:noreply, socket}
  end

  @impl Slipstream
  def handle_info({:after_join, something}, socket) do
    Logger.debug("Edge.Client received: :after_join #{inspect(something)}")
    Edge.Application.start_scape(socket.assigns.edge_init.id)
    {:noreply, socket}
  end

  @impl Slipstream
  def handle_info({@presence_changed_v1, presence_list}, socket) do
    Logger.alert("Edge.Client received: [#{@presence_changed_v1}] \n #{inspect(presence_list)}")
    {:noreply, socket}
  end

  @impl Slipstream
  def handle_info(msg, socket) do
    Logger.alert("Edge.Client received: #{inspect(msg)}")
    {:noreply, socket}
  end

  ############ PLUMBING ################
  def to_name(edge_id),
    do: "edge.client:#{edge_id}"

  def to_topic(edge_id),
    do: "edge:lobby:#{edge_id}"

  def via(edge_id),
    do: Edge.Registry.via_tuple({:client, to_name(edge_id)})

  def child_spec(edge_init) do
    config = Application.fetch_env!(:swai_edge, __MODULE__)

    %{
      id: to_name(edge_init.id),
      start: {__MODULE__, :start_link, [%{config: config, edge_init: edge_init}]},
      restart: :transient,
      type: :worker
    }
  end

  def start_link(args),
    do:
      Slipstream.start_link(
        __MODULE__,
        args,
        name: via(args.edge_init.id)
      )
end
