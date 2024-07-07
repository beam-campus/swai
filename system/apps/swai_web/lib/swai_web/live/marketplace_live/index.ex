defmodule SwaiWeb.MarketplaceLive.Index do
  use SwaiWeb, :live_view

  @moduledoc """
  The live view for the training grounds index page.
  """

  alias Edges.Service, as: Edges
  alias Swai.Biotopes, as: Biotopes

  @impl true
  def mount(_params, _session, socket) do
    biotopes = Biotopes.list_biotopes()
    active_models = Enum.filter(biotopes, & &1.is_active?)
    inactive_models = Enum.reject(biotopes, & &1.is_active?)

    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign(
           edges: Edges.get_all(),
           active_models: active_models,
           inactive_models: inactive_models,
           now: DateTime.utc_now(),
           page_title: "Marketplace",
           show_init_swarm_modal: false,
           current_biotope_id: nil
         )}

      false ->
        {:ok,
         socket
         |> assign(
           edges: Edges.get_all(),
           active_models: active_models,
           inactive_models: inactive_models,
           now: DateTime.utc_now(),
           page_title: "Marketplace",
           show_init_swarm_modal: false,
           current_biotope_id: nil
         )}
    end
  end

  @impl true
  def handle_event("init_swarm", _params, socket) do
    {:noreply,
     socket
     |> assign(
       show_init_swarm_modal: not socket.assigns.show_init_swarm_modal,
       current_biotope_id: socket.assigns.current_biotope_id
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="marketplace-view" class="flex flex-col my-5">
      <section class="py-3">
        <.live_component
            id="active-models-section"
            module={SwaiWeb.MarketplaceLive.ModelsSection}
            edges={@edges}
            biotopes={@active_models}
            now={@now}
            section_title="Available Ecosystems"
            section_description="
            Please do keep in mind that right now, only one swarm can be trained on the free plan."
        />
      </section>
      <section class="py-3">
        <.live_component
            id="inactive-models-section"
            module={SwaiWeb.MarketplaceLive.ModelsSection}
            edges={@edges}
            biotopes={@inactive_models}
            now={@now}
            section_title="Coming soon..."
            section_description="Do you want to see these models to become available for your research or entertainment?
            Then do consider supporting our efforts by buying us a coffee or by becoming part of a community that
            is dedicated to this different form of AI!"
        />
      </section>
    </div>
    """
  end
end
