defmodule SwaiWeb.MarketplaceLive.ModelsSection do
  use SwaiWeb, :live_component

  alias Schema.Biotope, as: Biotope


  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="marketplace-models-section" class="px-2">
      <div class="header-section py-2 px-5 text-white">
        <h2> <%= @section_title %> </h2>
        <p class="text-sm font-mono"> <%= @section_description %> </p>
      </div>
      <div class="cards-section grid grid-cols-2 md:grid-cols-1 gap-4">
        <%= for biotope <- @biotopes do %>
          <.live_component
            id={"section-card-#{biotope.id}"}
            module={SwaiWeb.MarketplaceLive.ModelCard}
            biotope={biotope}
          />
        <% end %>
      </div>
    </div>
    """
  end


end
