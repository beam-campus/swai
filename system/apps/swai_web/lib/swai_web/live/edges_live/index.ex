defmodule SwaiWeb.EdgesLive.Index do
  use SwaiWeb, :live_view

  require Logger
  require Seconds
  require Jason.Encoder

  alias Edges.Service, as: EdgesCache
  alias Phoenix.PubSub
  alias Edge.Facts, as: EdgeFacts
  alias Edge.Init, as: Edge

  @edges_cache_updated_v1 EdgeFacts.edges_cache_updated_v1()
  @edge_attached_v1 EdgeFacts.edge_attached_v1()
  @edge_detached_v1 EdgeFacts.edge_detached_v1()

  # def refresh(_caller_state),
  #   do: Process.send(self(), :refresh, @refresh_seconds * 1_000)

  @impl true
  def mount(_params, _session, socket) do
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
            now: DateTime.utc_now()
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
            now: DateTime.utc_now()
          )
        }
    end
  end

  @impl true
  def handle_info({@edges_cache_updated_v1, _payload}, socket) do
    Logger.alert("Edges updated")

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

        <section class="top-hidden-section">
        </section>

        <section class="top-section">
          <.live_component
            id="edges-header"
            module={SwaiWeb.EdgesLive.EdgesHeader}
            edges={@edges}
          />
        </section>

        <section
          id="edges-map"
          class="flex justify-center"
        >
          <.live_component
            id="edge-world-map"
            module={SwaiWeb.EdgeBrowser.WorldMap}
            edges={@edges}
          />
        </section>

    </div>
    """
  end
end
