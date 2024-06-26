defmodule SwaiWeb.EdgesLive.Index do
  use SwaiWeb, :live_view

  require Logger
  require Seconds

  alias Edges.Service, as: EdgesCache
  alias Phoenix.PubSub
  alias Edge.Facts, as: EdgeFacts
  alias Edge.Init, as: Producer

  # @edges_cache_updated_v1 EdgeFacts.edges_cache_updated_v1()

  # def refresh(_caller_state),
  #   do: Process.send(self(), :refresh, @refresh_seconds * 1_000)

  @impl true
  def mount(_params, _session, socket) do
    case connected?(socket) do
      true ->
        Logger.info("Connected")
        PubSub.subscribe(Swai.PubSub, EdgeFacts.edges_cache_updated_v1())
        {
          :ok,
          socket
          |> assign(
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
            edges: [],
            now: DateTime.utc_now()
          )
        }
    end
  end

  # @impl true
  # def handle_info({@edges_cache_updated_v1, _payload}, socket) do

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
  def handle_info(_msg, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-screen h-full py-1 font-mono justify-left">
    <div class="flex flex-col items-center justify-center lt-view-gradient">
    <div>
      <h1 class="text-2xl font-normal text-white font-brand">
        Connected Producers
      </h1>
    </div>
    <div class="px-2 m-1 text-sm text-white font-brand font-regular">
      <%= edges_count = Enum.count(@edges)
        if edges_count > 0 do %>
        <%= edges_count %> producer(s) connected
      <% else %>
        awaiting producers...
      <% end %>
    </div>
    </div>
      <.live_component
      module={SwaiWeb.BreadCrumbsBar}
      id={"_farms_breadcrumbs"}
    />


    <div class="px-8">
    <div class="flex flex-col w-full gap-2 text-sm text-white" >
    <%= if @current_user do %>
      <.live_component
        module={SwaiWeb.EdgesLive.EdgesGrid}
        id={"edges_grid_" <> @current_user.id}
        edges={@edges}
        current_user={@current_user}
      />
    <% end %>
    </div>
    </div>
    </div>
    """
  end
end
