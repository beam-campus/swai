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
    <div class="swarm-license-card">
      <div class="card-image">
        <img src={"#{@biotope.image_url} "} alt="Biotope Image" />
      </div>
      <div class="card-header">
        <p class="card-header-title">Swarm License Details</p>
      </div>
      <div class="card-content">
        <div class="content">
          <p><strong>License ID:</strong> <%= @swarm_license.id %> </p>
          <p><strong>Swarm Name:</strong> <%= @current_user.user_name %></p>
          <p><strong>Issued Date:</strong> <%= @swarm_license.valid_from %></p>
          <p><strong>Expiry Date:</strong> <%= @swarm_license.valid_until %></p>
          <p><strong>Biotope:</strong> <%= @biotope.name %></p>
          <!-- Add more details as necessary -->
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def render1(assigns) do
    ~H"""
    <div class="card" style="box-shadow: 0 4px 8px rgba(0,0,0,0.1); margin: 20px; padding: 20px; border-radius: 8px;">
      <div class="card-header" style="padding-bottom: 20px; border-bottom: 1px solid #eee; margin-bottom: 20px;">
        <p class="card-header-title" style="font-size: 20px; font-weight: bold;">Swarm License Details</p>
      </div>
      <div class="card-content">
        <div class="content">
          <p><strong>License ID:</strong> <%= @swarm_license.id %> </p>
          <p><strong>Swarm Name:</strong> <%= @current_user.user_name %></p>
          <p><strong>Swarm Size:</strong> {@swarm_license.size}</p>
          <p><strong>Issued Date:</strong> {@swarm_license.issued_date}</p>
          <p><strong>Expiry Date:</strong> {@swarm_license.expiry_date}</p>
          <!-- Add more details as necessary -->
        </div>
      </div>
    </div>
    """
  end

end
