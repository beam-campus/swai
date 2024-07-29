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
    <div class="flex flex-col">
    <%= for swarm_training <- @swarm_trainings do %>
      <.live_component
        module={SwaiWeb.MyWorkspaceLive.SwarmTrainingCard}
        id={"swarm-training-card-#{swarm_training.id}"}
        swarm_training={swarm_training}
      />
    <% end %>
    </div>
    """
  end

end
