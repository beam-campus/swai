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
    <div class="swarm-license-card inactive-biotope">

      <div class="card-image">
        <img src={"#{@biotope.image_url} "} alt="Biotope Image" />
      </div>
      <div class="flex-row" id={"swarm-license-content-#{@swarm_license.id}"} >
        <div class="section-card-body w-1/2">
          <p class="text-sm font-medium uppercase">
            <%= @biotope.theme %>
          </p>
          <p
          class="mt-1 text-xl font-semibold text-ltRed-light" >
            <%= @biotope.name %>
          </p>
        </div>
      </div>
      <div class="flex flex-col w-1/2" id={"swarm-license-details-#{@swarm_license.id}"}>
        <p class="text-base text-white">
              <%= @biotope.description %>
      </p>
      <div class="flex flex-row mt-1">
            <p class="text-base text-red-500">
              <%= @biotope.challenges %>
            </p>
            <p class="text-base text-green-500">
              <%= @biotope.objective %>
            </p>
       </div>
      <div class="flex flex-row mt-1">
            <p class="text-base text-red-500">
              <%= "#{inspect(@swarm_license.id)}" %>
            </p>

      </div>

      </div>
    </div>
    """
  end
end
