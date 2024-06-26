defmodule SwaiWeb.ViewScapesLive.Index do
  use SwaiWeb, :live_view

  @moduledoc """
  The live view for the scapes index.
  """

  alias Phoenix.PubSub

  require Logger

  alias Edge.Facts, as: EdgeFacts
  alias Scape.Facts, as: ScapeFacts

  @edges_cache_updated_v1 EdgeFacts.edges_cache_updated_v1()
  @scapes_cache_updated_v1 ScapeFacts.scapes_cache_updated_v1()

  @impl true
  def mount(_params, _session, socket) do
    case connected?(socket) do
      true ->
        Logger.info("Connected")
        PubSub.subscribe(Swai.PubSub, @edges_cache_updated_v1)
        PubSub.subscribe(Swai.PubSub, @scapes_cache_updated_v1)

        {:ok,
         socket
         |> assign(
           scapes: Scapes.Service.get_all(),
           edges: Edges.Service.get_all()
         )}

      false ->
        Logger.info("Not connected")

        {:ok,
         socket
         |> assign(
           scapes: [],
           edges: []
         )}
    end
  end

  ########## CALLBACKS ##########

  @impl true
  def handle_info({@scapes_cache_updated_v1, _payload}, socket) do
    {
      :noreply,
      socket
      |> assign(scapes: Scapes.Service.get_all())
      |> put_flash(:success, "Scapes updated")
    }
  end

  @impl true
  def handle_info({@edges_cache_updated_v1, _payload}, socket) do
    {
      :noreply,
      socket
      |> assign(edges: Edges.Service.get_all())
      |> put_flash(:success, "Edges updated")
    }
  end

  @impl true
  def handle_info(_msg, socket),
    do:
      {:noreply,
       socket
       |> assign(
         scapes: Scapes.Service.get_all(),
         edges: Edges.Service.get_all()
       )}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-screen py-1 font-mono justify-left">
    <div class="flex flex-col items-center justify-center lt-view-gradient">
      <div>
        <h1 class="text-2xl font-normal text-white font-brand">
          Active Scapes
        </h1>
      </div>
      <div class="px-2 m-1 text-sm text-white font-brand font-regular">
        <%=
          _scapes_count = Enum.count(@scapes)
          edges_count = Enum.count(@edges)
          if edges_count > 0 do
        %>
          <%= edges_count %> producer(s) connected
        <% else %>
          awaiting producers...
        <% end %>
      </div>
    </div>
    <.live_component
    module={SwaiWeb.BreadCrumbsBar}
    id={@current_user.id <> "_scapes_breadcrumbs"}
    />
    <.live_component
    module={SwaiWeb.ViewScapesLive.ScapesGrid}
    id={@current_user.id <> "_scapes_grid"}
    scapes={@scapes}
    />
    </div>
    """
  end

end
