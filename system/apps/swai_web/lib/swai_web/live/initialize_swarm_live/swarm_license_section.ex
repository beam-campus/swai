defmodule SwaiWeb.InitializeSwarmLive.SwarmLicenseSection do
  use SwaiWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end


  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-sm rounded overflow-hidden shadow-lg bg-white">
    <.live_component
      id={"init-swarm-license-#{@swarm_license.id}"}
      module={SwaiWeb.InitializeSwarmLive.SwarmLicenseCard}
      swarm_license={@swarm_license}
      current_user={@current_user}
      biotope={@biotope}
    />
    </div>
    """
  end



end
