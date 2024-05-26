defmodule LogatronWeb.ViewFarmsLive.Index do
  use LogatronWeb, :live_view
  alias Phoenix.PubSub
  alias Edge.Facts, as: EdgeFacts
  alias MngFarm.Facts, as: FarmFacts

  require Logger

  @edges_cache_updated_v1 EdgeFacts.edges_cache_updated_v1()
  @farms_cache_updated_v1 FarmFacts.farms_cache_updated_v1()

  @impl true
  def mount(_params, _session, socket) do
    case connected?(socket) do
      true ->
        Logger.info("Connected")
        PubSub.subscribe(Logatron.PubSub, @edges_cache_updated_v1)
        PubSub.subscribe(Logatron.PubSub, @farms_cache_updated_v1)

        {
          :ok,
          socket
          |> assign(
            farms: Farms.Service.get_all(),
            edges: Edges.Service.get_all()
          )
        }

      false ->
        Logger.info("Not connected")

        {:ok,
         socket
         |> assign(
           farms: [],
           edges: []
         )}
    end
  end

  @impl true
  def handle_info({@edges_cache_updated_v1, _payload}, socket),
    do: {
      :noreply,
      socket
      |> assign(:farms, Edges.Service.get_all())
    }

  @impl true
  def handle_info({@farms_cache_updated_v1, _payload}, socket),
    do: {
      :noreply,
      socket
      |> assign(:farms, Farms.Service.get_all())
    }

  @impl true
  def handle_info(_msg, socket),
    do: {
      :noreply,
      socket
      |> assign(
        farms: Farms.Service.get_all(),
        edges: Edges.Service.get_all()
      )
    }

  @impl true
  def handle_event("show_field", %{"id" => id} = _value, socket) do
    Logger.info("show field for farm: #{inspect(id)}")

    {
      :noreply,
      socket
      |> push_redirect(to: ~p"/view_fields?mng_farm_id=#{id}")
    }
  end
end
