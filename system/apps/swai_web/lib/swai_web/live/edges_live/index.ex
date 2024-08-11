defmodule SwaiWeb.EdgesLive.Index do
  use SwaiWeb, :live_view

  require Logger
  require Seconds

  alias Edges.Service,
    as: EdgesCache

  alias Phoenix.PubSub

  alias Edge.Facts,
    as: EdgeFacts

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

  # @impl true
  # def handle_info({@edges_cache_updated_v1, _payload}, socket) do
  #   Logger.info("Edges updated")
  #   {
  #     :noreply,
  #     socket
  #     |> assign(
  #       edges: EdgesCache.get_all(),
  #       now: DateTime.utc_now()
  #     )
  #   }
  # end

  @impl true
  def handle_info(_msg, socket),
    do: {
      :noreply,
      socket
      |> assign(
        edges: EdgesCache.get_all(),
        now: DateTime.utc_now()
      )
    }

  @impl true
  def render(assigns) do
    ~H"""
    <div id="edges-world-map-div" class="flex flex-col w-full h-full ml-4">
      <svg id="edges-world-map-svg" class="w-full h-full" phx-hook="TheMap" phx-edges="{@edges}" />
    </div>
    """
  end

  @impl true
  def render2(assigns) do
    ~H"""
    <div class="flex flex-col w-screen h-full py-1 font-mono justify-left">
      <div class="px-8">
        <div class="flex flex-col w-full gap-2 text-sm text-white">
          <%= if @current_user do %>
            <.live_component
              module={SwaiWeb.EdgesLive.EdgesGrid}
              id={"edges_grid_" <> @current_user.id}
              edges={@edges}
              current_user={@current_user}
            />
          <% else %>
            <div class="text-sm text-white font-brand font-regular">
              Please sign in or register to view connected producers
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
