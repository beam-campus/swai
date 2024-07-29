defmodule SwaiWeb.MyWorkspaceLive.SwarmTrainingCard do
  use SwaiWeb, :live_component

  alias Schema.SwarmTraining, as: SwarmTraining
  alias Schema.SwarmTraining.Status, as: Status

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  attr(:swarm_training, SwarmTraining)

  defp card_header(assigns) do
    ~H"""
    <div class="section-card-header flex items-center">
      <p class="text-xl font-regular text-swBrand-dark"><%= @swarm_training.biotope_name %></p>
      <p class="ml-10 font-regular text-swBrand-light"> <%= @swarm_training.swarm_name %></p>
      <p class="ml-10 font-regular text-swBrand-light"> <%= @swarm_training.swarm_id %></p>
      <span class={"ml-auto border rounded p-1 font-regular text-xs badge #{status_class(@swarm_training.status)}"}><%= Schema.SwarmTraining.Status.to_string(@swarm_training.status) %></span>
    </div>
    """
  end

  attr(:swarm_training, SwarmTraining)

  defp card_body(assigns) do
    ~H"""
    <div class="section-card-body">
      <div class="section">
        <div class="flex flex-row justify-between">
            <p><strong>Size:</strong> <%= @swarm_training.swarm_size %> particles</p>
            <p><strong>Swarming time:</strong> <%= @swarm_training.generation_epoch_in_minutes %> minutes</p>
            <p><strong>Cost:</strong> <%= @swarm_training.cost_in_tokens %> tokens</p>
        </div>
      </div>
    </div>
    """
  end

  attr(:swarm_training, SwarmTraining)

  defp card_footer(assigns) do
    ~H"""
    <div class="section-card-footer flex flex-row">
      <.button class="btn-observe">Observe the Swarm</.button>
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="section-card bg-white shadow-md rounded-lg p-4 mb-4">
      <.card_header swarm_training={@swarm_training}  />
      <.card_body swarm_training={@swarm_training} />
      <.card_footer swarm_training={@swarm_training} />
    </div>
    """
  end

  defp status_class(status) do
    case status do
      # Assuming 0 is unknown
      0 -> "bg-gray-500 text-white"
      # Assuming 1 is active
      1 -> "bg-green-500 text-white"
      # Assuming 2 is completed
      2 -> "bg-blue-500 text-white"
      # Default case
      _ -> "bg-red-500 text-white"
    end
  end

  defp status_text(status) do
    case status do
      # Assuming 0 is unknown
      0 -> "Unknown"
      # Assuming 1 is active
      1 -> "Active"
      # Assuming 2 is completed
      2 -> "Completed"
      # Default case
      _ -> "Unknown"
    end
  end

  defp active_class(true), do: "active-biotope"
  defp active_class(false), do: "inactive-biotope"
end
