defmodule SwaiWeb.InitializeSwarmLive.UserInfoCard do
  use SwaiWeb, :live_component

  alias Schema.User, as: User

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class="card user-info-card border rounded-lg shadow-sm py-3 px-4"
      style="box-shadow: 0 2px 4px rgba(0,0,0,.1);">
      <div class="card-content">
        <div class="media" style="align-items: center;">
          <div class="media-left">
            <figure class="image is-64x64">
              <img src={@current_user.image_url} alt={"#{@current_user.alias}'s avatar"} class="is-rounded">
            </figure>
          </div>
          <div class="media-content">
            <p class="title is-4" style="margin-bottom: 0;"><%= @current_user.alias %></p>
            <p class="subtitle is-6" style="display: flex; align-items: center;">
              <span class="icon" style="margin-right: 5px;">
                <i class="fas fa-envelope"></i>
              </span>
              <%= @current_user.email %>
            </p>
          </div>
        </div>
      </div>
      <footer class="card-footer" style="background: #f5f5f5; justify-content: center;">
        <a href="#" class="card-footer-item">View Profile</a>
        <!-- Add more footer items as needed -->
      </footer>
    </div>
    """
  end
end
