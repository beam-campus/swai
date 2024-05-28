defmodule SwaiWeb.ViewRegionsLive.Index do
  use SwaiWeb, :live_view

  alias Phoenix.PubSub
  alias Edge.Facts, as: EdgeFacts
  alias Region.Facts, as: RegionFacts

  require Logger

  @regions_cache_updated_v1 RegionFacts.regions_cache_updated_v1()
  @edges_cache_updated_v1 EdgeFacts.edges_cache_updated_v1()

  @impl true
  def mount(_params, _session, socket) do
    case connected?(socket) do
      true ->
        Logger.info("Connected")
        PubSub.subscribe(Swai.PubSub, @regions_cache_updated_v1)
        PubSub.subscribe(Swai.PubSub, @edges_cache_updated_v1)

        {
          :ok,
          socket
          |> assign(
            edges: Edges.Service.get_all(),
            regions: Regions.Service.get_all()
          )
        }

      false ->
        Logger.info("Not connected")

        {:ok,
         socket
         |> assign(
           edges: [],
           regions: []
         )}
    end
  end

  @impl true
  def handle_info({@edges_cache_updated_v1, _payload}, socket),
    do: {
      :noreply,
      socket
      |> assign(:regions, Edges.Service.get_all())
    }

  @impl true
  def handle_info({@regions_cache_updated_v1, _payload}, socket),
    do: {
      :noreply,
      socket
      |> assign(:regions, Regions.Service.get_all())
    }

  @impl true
  def handle_info(_msg, socket),
    do: {
      :noreply,
      socket
      |> assign(
        edges: Edges.Service.get_all(),
        regions: Regions.Service.get_all()
      )
    }
end
