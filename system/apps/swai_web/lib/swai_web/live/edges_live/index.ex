defmodule SwaiWeb.EdgesLive.Index do
  use SwaiWeb, :live_view

  require Logger
  require Seconds
  require Jason.Encoder

  alias Edges.Service, as: EdgesCache
  alias Phoenix.PubSub
  alias Edge.Facts, as: EdgeFacts

  import ErlUtils

  @edges_cache_updated_v1 EdgeFacts.edges_cache_updated_v1()

  # def refresh(_caller_state),
  #   do: Process.send(self(), :refresh, @refresh_seconds * 1_000)

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :count_messages, 1_000)

    case connected?(socket) do
      true ->
        Logger.info("Connected")
        PubSub.subscribe(Swai.PubSub, @edges_cache_updated_v1)

        {
          :ok,
          socket
          |> assign(
            page_title: "Hives",
            edges: EdgesCache.get_all(),
            now: DateTime.utc_now(),
            nbr_of_msgs: count_messages()
          )
        }

      false ->
        Logger.info("Not connected")

        {
          :ok,
          socket
          |> assign(
            page_title: "Hives",
            edges: EdgesCache.get_all(),
            now: DateTime.utc_now(),
            nbr_of_msgs: count_messages()
          )
        }
    end
  end

  @impl true
  def handle_info(:count_messages, socket) do
    Process.send_after(self(), :count_messages, 10_000)
    # old_nbr_of_msgs = total_messages()
    nbr_of_processes = ErlUtils.total_processes()

    {:noreply, socket |> assign(nbr_of_msgs: nbr_of_processes)}
  end

  @impl true
  def handle_info({@edges_cache_updated_v1, _payload}, socket) do
    {
      :noreply,
      socket
      |> assign(
        edges: EdgesCache.get_all(),
        now: DateTime.utc_now()
      )
    }
  end

  @impl true
  def handle_info(_msg, socket) do
    {
      :noreply,
      socket
      |> assign(
        edges: EdgesCache.get_all(),
        now: DateTime.utc_now()
      )
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col mr-5 ml-5 h-full">
      <section class="top-hidden-section"></section>

      <section class="top-section">
        <.live_component
          id="edges-header"
          module={SwaiWeb.EdgesLive.EdgesHeader}
          edges={@edges}
          nbr_of_msgs={@nbr_of_msgs}
        />
      </section>

      <section id="edges-map" class="flex justify-center">
        <.live_component id="edge-world-map" module={SwaiWeb.EdgeBrowser.WorldMap} edges={@edges} />
      </section>
    </div>
    """
  end
end
