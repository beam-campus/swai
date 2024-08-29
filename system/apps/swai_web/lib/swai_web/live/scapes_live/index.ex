defmodule SwaiWeb.ScapesLive.Index do
  use SwaiWeb, :live_view

  @moduledoc """
  The live view for the scapes index.
  """

  alias Phoenix.PubSub

  require Logger

  alias Edge.Facts, as: EdgeFacts
  alias Scape.Facts, as: ScapeFacts
  alias Edges.Service, as: Edges
  alias Scapes.Service, as: Scapes

  @edges_cache_updated_v1 EdgeFacts.edges_cache_updated_v1()
  @scapes_cache_updated_v1 ScapeFacts.scapes_cache_updated_v1()

  @impl true
  def mount(_params, _session, socket) do
    case connected?(socket) do
      true ->
        Logger.info("Connected")

        Swai.PubSub
        |> PubSub.subscribe(@edges_cache_updated_v1)

        Swai.PubSub
        |> PubSub.subscribe(@scapes_cache_updated_v1)

        {:ok,
         socket
         |> assign(
           page_title: "Scapes",
           scapes: Scapes.get_all(),
           edges: Edges.get_all()
         )}

      false ->
        Logger.info("Not connected")

        {:ok,
         socket
         |> assign(
           page_title: "Scapes",
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
      |> assign(scapes: Scapes.get_all())
      |> put_flash(:success, "Scapes updated")
    }
  end

  @impl true
  def handle_info({@edges_cache_updated_v1, _payload}, socket) do
    {
      :noreply,
      socket
      |> assign(edges: Edges.get_all())
      |> put_flash(:success, "Edges updated")
    }
  end

  @impl true
  def handle_info(_msg, socket),
    do:
      {:noreply,
       socket
       |> assign(
         scapes: Scapes.get_all(),
         edges: Edges.get_all()
       )}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-screen py-1 font-mono justify-center items-center">
      <.live_component
      module={SwaiWeb.ScapesLive.ScapesGrid}
      id={@current_user.id <> "_scapes_grid"}
      scapes={@scapes}
      current_user={@current_user}
      />
    </div>
    """
  end
end
