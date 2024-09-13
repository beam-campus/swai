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
      <div class="px-5 text-white">
        <h2><%= @section_title %></h2>
        <p class="text-sm font-brand"><%= @section_description %></p>
      </div>

      <div class="grid grid-cols-1 gap-4 mt-3">
        <%= for license <- @licenses do %>
          <.live_component
            id={"swarm-training-card-#{license.license_id}"}
            module={SwaiWeb.MyWorkspaceLive.SwarmLicenseCard}
            license={license}
            current_user={@current_user}
          />
        <% end %>
      </div>
    </div>
    """
  end
end
