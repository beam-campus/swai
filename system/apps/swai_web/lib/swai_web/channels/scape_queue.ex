defmodule SwaiWeb.ScapeQueue do
  @moduledoc """
  The ScapeQueue is used to broadcast messages to all clients
  """
  use GenServer

  alias Phoenix.PubSub, as: PubSub

  alias Swai.PubSub, as: SwaiPubSub
  alias TrainSwarmProc.Facts, as: TrainSwarmFacts
  alias Scape.Init, as: ScapeInit

  alias TrainSwarmProc.QueueScape.EvtV1, as: ScapeQueued

  alias Edges.Service, as: Edges

  require Logger

  @scape_queued_v1 TrainSwarmFacts.scape_queued()

  ####### inspect_queue ############################
  def inspect_queue() do
    GenServer.call(__MODULE__, :inspect_queue)
  end

  ################# INIT ##########################

  @impl true
  def init(_init_args \\ []) do
    Logger.alert("!!!!!!!!!!!    SCAPE QUEUE IS UP => #{inspect(self())} !!!!!!!!!!!")

    SwaiPubSub
    |> PubSub.subscribe(@scape_queued_v1)

    Process.send_after(self(), :pop_queue, 5_000)

    {:ok, []}
  end

  ################# HANDLE_SCAPE_QUEUED ###########

  @impl true
  def handle_info(
        {@scape_queued_v1, %ScapeQueued{payload: payload} = evt, _metadata},
        state
      ) do
    Logger.info("handle_info #{@scape_queued_v1} #{inspect(evt)}")

    {:ok, scape} = ScapeInit.from_map(%ScapeInit{}, payload)

    Logger.alert("!!!!!!!!!!!    SELECTING EDGE FOR BIOTOPE [#{scape.biotope_id}] !!!!!!!!!!!")

    edge =
      Edges.get_candidates_for_biotope(scape.biotope_id)
      |> Enum.random()

    state = state ++ {edge, scape}

    {:noreply, state}
  end

  ################# POP_QUEUE #####################
  @impl true
  def handle_info(:pop_queue, []) do
    Logger.info("handle_info :pop_queue for empty queue")
    {:noreply, []}
  end

  @impl true
  def handle_info(:pop_queue, [{edge, scape} | rest]) do
    Logger.info("handle_info :pop_queue")

    SwaiWeb.EdgeChannel.start_scape(edge, scape)

    Process.send_after(self(), :pop_queue, 5_000)

    {:noreply, rest}
  end

  #################### PLUMBING ###################

  def start_link(init_args) do
    GenServer.start_link(
      __MODULE__,
      init_args,
      name: __MODULE__
    )
  end

  def child_spec(init_args),
    do: %{
      id: __MODULE__,
      start: {
        __MODULE__,
        :start_link,
        [init_args]
      },
      type: :worker
    }

  def via(key),
    do: Swai.Registry.via_tuple({:scape_queue, to_name(key)})

  def via_sup(key),
    do: Swai.Registry.via_tuple({:scape_queue_sup, to_name(key)})

  def to_name(key) when is_bitstring(key),
    do: "scape.system.#{key}"
end
