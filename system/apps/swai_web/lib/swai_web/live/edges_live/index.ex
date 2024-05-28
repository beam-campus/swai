defmodule SwaiWeb.EdgesLive.Index do
  use SwaiWeb, :live_view

  require Logger
  require Seconds

  alias Edges.Service, as: EdgesCache
  alias Phoenix.PubSub
  alias Edge.Facts, as: EdgeFacts

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
end
