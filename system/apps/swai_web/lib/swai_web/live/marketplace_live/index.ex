defmodule SwaiWeb.MarketplaceLive.Index do
  use SwaiWeb, :live_view

  @moduledoc """
  The live view for the training grounds index page.
  """

  alias Edges.Service, as: Edges
  alias Swai.Biotopes, as: Biotopes

  def mount(_params, _session, socket) do
    biotopes = Biotopes.list_biotopes()
    active_models = Enum.filter(biotopes, &(&1.is_active?))
    inactive_models = Enum.reject(biotopes, &(&1.is_active?))

    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign(
           edges: Edges.get_all(),
           active_models: active_models,
           inactive_models: inactive_models,
           now: DateTime.utc_now(),
           page_title: "Marketplace"
         )}

      false ->
        {:ok,
         socket
         |> assign(
           edges: Edges.get_all(),
           active_models: active_models,
           inactive_models: inactive_models,
           now: DateTime.utc_now(),
           page_title: "Marketplace"
         )}
    end
  end

  def render(assigns) do
    ~H"""
    <div id="marketplace-view" class="flex flex-col my-5">
      <section class="py-3">
        <.live_component
            id="active-models-section"
            module={SwaiWeb.MarketplaceLive.ModelsSection}
            edges={@edges}
            training_grounds={@active_models}
            now={@now}
            section_title="Models"
            section_description="These are the Darwinian models that are currently available.
            Click 'Train a Swarm' to start training your Evolutionary AI Swarm.
            Do keep in mind that currently only one swarm can be trained on the free plan."
        />
      </section>
      <section class="py-3">
        <.live_component
            id="inactive-models-section"
            module={SwaiWeb.MarketplaceLive.ModelsSection}
            edges={@edges}
            training_grounds={@inactive_models}
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
