defmodule SwaiWeb.TrainingGroundsLive.TrainingGroundsListView do
  use SwaiWeb, :live_component

  alias Swai.Biotopes,  as: Biotopes

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
def render(assigns) do
  ~H"""
  <div id="training-grounds-list-view" class="flex flex-col gap-4 p-4">
    <%= for training_ground <- @training_grounds do %>
      <.live_component
        id={"training-ground-card-#{training_ground.id}"}
        module={SwaiWeb.TrainingGroundsLive.TrainingGroundCard}
        training_ground={training_ground}
      />
    <% end %>
  </div>
  """
end


end
