defmodule SwaiWeb.InitializeSwarmLive.SwarmSpecificationSection do
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
    <section>
      <.live_component
        id={"init-swarm-specs-#{@swarm_license.id}"}
        module={SwaiWeb.InitializeSwarmLive.SwarmSpecsCard}
        swarm_license={@swarm_license}
        swarm_specs={@swarm_specs}
      />

    </section>
    """
  end
end
