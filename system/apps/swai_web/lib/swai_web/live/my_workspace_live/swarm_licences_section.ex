defmodule SwaiWeb.MyWorkspaceLive.SwarmLicensesSection do
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


      <div class="cards-section grid grid-cols-1 gap-4 mt-3">
        <%= for swarm_license <- @swarm_licenses do %>
          <.live_component
            id={"swarm-training-card-#{swarm_license.license_id}"}
            module={SwaiWeb.MyWorkspaceLive.SwarmLicenseCard}
            swarm_license={swarm_license}
          />
        <% end %>
      </div>


    </div>
    """
  end

  defp status_class(status) do
    case status do
      :active -> "bg-green-500"
      :inactive -> "bg-gray-500"
      :completed -> "bg-blue-500"
      _ -> "bg-red-500"
    end
  end


end
