defmodule SwaiWeb.InitializeSwarmLive.SwarmLicenseCard do
  use SwaiWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
  }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-xl mx-auto bg-white shadow-lg rounded-lg overflow-hidden">
      <div class="px-6 py-4">
        <div class="font-serif text-xl font-bold text-gray-900 mb-2 text-center">Swarm License Agreement</div>
        <p class="text-base text-gray-700 mt-4">
          This license is hereby granted to <span class="font-semibold"><%= @current_user.email %></span>,
          authorizing the evolution of swarms with a maximum size of <span class="font-semibold"><%= @swarm_license.max_population %> workers</span>,
          over <span class="font-semibold"><%= @swarm_license.max_generations %> generations</span>,
          effective between <span class="font-semibold"><%= @swarm_license.valid_from %></span> and <span class="font-semibold"><%= @swarm_license.valid_until %></span>,
          within the <span class="font-semibold"><%= @biotope.name %></span> ecosystem.
        </p>
      </div>
      <div class="px-6 pt-4 pb-2 text-center">
        <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-full">
          Accept License
        </button>
      </div>
    </div>
    """
  end

end
