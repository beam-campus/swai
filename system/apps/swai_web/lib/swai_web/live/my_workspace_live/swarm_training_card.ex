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
    <div class="card-header flex justify-between items-center mb-2">
      <h2 class="text-xl font-semibold"><%= @swarm_training.biotope_name %></h2>
      <p><strong>Swarm ID:</strong> <%= @swarm_training.swarm_id %></p>
      <span class={"badge #{status_class(@swarm_training.status)}"}><%= Schema.SwarmTraining.Status.to_string(@swarm_training.status) %></span>
    </div>
    """
  end

  attr(:swarm_training, SwarmTraining)

  defp card_body(assigns) do
    ~H"""
    <div class="card-body">
      <div class="section mb-4">
        <h3 class="text-lg font-semibold mb-2">Configuration</h3>
        <div class="flex flex-row">
        <p><strong>Size:</strong> <%= @swarm_training.swarm_size %> particles</p>
        <p><strong># Iterations:</strong> <%= @swarm_training.nbr_of_generations %></p>
        <p><strong>Depth:</strong> <%= @swarm_training.drone_depth %> levels</p>
        <p><strong>Epoch:</strong> <%= @swarm_training.generation_epoch_in_minutes %> minutes</p>
        <p><strong>Take best:</strong> <%= @swarm_training.select_best_count %></p>
        <p><strong>Cost:</strong> <%= @swarm_training.cost_in_tokens %> tokens</p>
        </div>
      </div>
      <div class="section">
        <h3 class="text-lg font-semibold mb-2">Execution</h3>
        <p><strong>Run Time :</strong> <%= @swarm_training.total_run_time_in_seconds %> sec</p>
        <p><strong>Tokens Used:</strong> <%= @swarm_training.tokens_used %></p>
        <p><strong>Budget in Tokens:</strong> <%= @swarm_training.budget_in_tokens %></p>
      </div>
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="card bg-white shadow-md rounded-lg p-4 mb-4">
      <.card_header swarm_training={@swarm_training}  />

      <%!-- <div class="card-header flex justify-between items-center mb-2">
        <h2 class="text-xl font-semibold"><%= @swarm_training.biotope_name %></h2>
        <p><strong>Swarm ID:</strong> <%= @swarm_training.swarm_id %></p>
        <span class={"badge #{status_class(@swarm_training.status)}"}><%= @swarm_training.status %></span>
      </div> --%>

      <div class="card-body">
        <div class="section mb-4">
          <h3 class="text-lg font-semibold mb-2">Configuration</h3>

          <div class="flex flex-row">

          <p><strong>Size:</strong> <%= @swarm_training.swarm_size %> particles</p>
          <p><strong># Iterations:</strong> <%= @swarm_training.nbr_of_generations %></p>
          <p><strong>Depth:</strong> <%= @swarm_training.drone_depth %> levels</p>
          <p><strong>Epoch:</strong> <%= @swarm_training.generation_epoch_in_minutes %> minutes</p>
          <p><strong>Take best:</strong> <%= @swarm_training.select_best_count %></p>
          <p><strong>Cost:</strong> <%= @swarm_training.cost_in_tokens %> tokens</p>
          </div>
        </div>
        <div class="section">
          <h3 class="text-lg font-semibold mb-2">Execution</h3>
          <p><strong>Run Time :</strong> <%= @swarm_training.total_run_time_in_seconds %> sec</p>
          <p><strong>Tokens Used:</strong> <%= @swarm_training.tokens_used %></p>
          <p><strong>Budget in Tokens:</strong> <%= @swarm_training.budget_in_tokens %></p>
        </div>
      </div>
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
end
