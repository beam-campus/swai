defmodule SwaiWeb.MyWorkspaceLive.SwarmTrainingsSection do
  use SwaiWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end


  @impl true
  def render(assigns) do
    ~H"""
    <div id="workspace-trainings-section" class="mx-4">
      <div class="header-section px-5 text-white">
        <h2> <%= @section_title %> </h2>
        <p class="text-sm font-brand"> <%= @section_description %> </p>
      </div>
      <div class="cards-section grid grid-cols-1 md:grid-cols-1 gap-4 mt-3">
      <%= for swarm_training <- @swarm_trainings do %>
      <.live_component
        module={SwaiWeb.MyWorkspaceLive.SwarmTrainingCard}
        id={"swarm-training-card-#{swarm_training.id}"}
        swarm_training={swarm_training}
      />
    <% end %>
    </div>
    </div>
    """
  end

end
