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
        <%= for training_ground <- @training_grounds do %>
          <.live_component
            id={"swai-model-card-#{training_ground.id}"}
            module={SwaiWeb.MarketplaceLive.ModelCard}
            training_ground={training_ground}
          />
        <% end %>
      </div>
    </div>
    """
  end


  def render2(assigns) do
    ~H"""
    <div id="training-grounds-list-view"
    class="grid grid-cols-2 md:grid-cols-1 gap-4 p-4">
       <header class="py-5 px-5 text-white">
          <h2 class="" >Active Training Grounds</h2>
          <p class="text-sm font-mono" >Description for active training grounds.</p>
        </header>

      <%= for training_ground <- @training_grounds |> Enum.filter(fn %Biotope{} = it -> it.is_active? end) do %>
        <.live_component
          id={"swai-model-card-#{training_ground.id}"}
          module={SwaiWeb.TrainingGroundsLive.TrainingGroundCard}
          training_ground={training_ground}
        />
      <% end %>
    </div>
    """
  end

end
