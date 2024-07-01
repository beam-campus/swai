defmodule SwaiWeb.MarketplaceLive.ModelCard do
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
    <div class={"swai-model-card " <> active_class(@training_ground.is_active?)}>
      <div class="swai-model-card-header">
        <img class="h-48 w-full object-cover opacity-80"
        src={"#{@training_ground.image_url}"} alt={"#{@training_ground.id}"}
        >
      </div>
      <div class="swai-model-card-body">
        <p class="text-sm font-medium text-lt-edit-gradient">
          <%= @training_ground.theme %>
        </p>
        <a href="#{Routes.training_ground_path(@socket, :show, @training_ground)}"
        class="block mt-2 text-xl font-semibold text-lt-section-header">
          <%= @training_ground.name %>
        </a>
        <p class="mt-3 text-base text-white">
          <%= @training_ground.description %>
        </p>
        <%= if @training_ground.is_active? do %>
          <div class="button-row mt-4 flex justify-between">
            <button class="btn-view">View</button>
            <button class="btn-train">Train a Swarm</button>
            <button class="btn-dashboard">Dashboard</button>
          </div>
        <% else %>
          <div class="button-row mt-4 flex justify-between">
            <button class="btn-view">View</button>
            <button class="btn-sponsor">Sponsor this Model</button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp active_class(true), do: "active-biotope"
  defp active_class(false), do: "inactive-biotope"
  def render2(assigns) do
    ~H"""
    <div class="swai-model-card">
      <div class="swai-model-card-header">
        <img class="h-48 w-full object-cover opacity-80"
        src={"#{@training_ground.image_url}"} alt={"#{@training_ground.id}"}
        >
      </div>
      <div class="swai-model-card-body">
        <p class="text-sm font-medium text-lt-edit-gradient">
          <%= @training_ground.theme %>
        </p>
        <a href="#{Routes.training_ground_path(@socket, :show, @training_ground)}"
        class="block mt-2 text-xl font-semibold text-lt-section-header">
          <%= @training_ground.name %>
        </a>
        <p class="mt-3 text-base text-white">
          <%= @training_ground.description %>
        </p>
        <%!-- <div class="mt-6 flex items-center">
          <a href="#{Routes.training_ground_path(@socket, :show, @training_ground)}"
          class="text-lt-edit-gradient hover:text-lt-section-header">
            View
          </a>
        </div> --%>
        <div class="button-row mt-4 flex justify-between">
          <button class="btn-view">View</button>
          <button class="btn-train">Train a Swarm</button>
          <button class="btn-dashboard">Dashboard</button>
        </div>
      </div>
    </div>
    """
  end

  def render1(assigns) do
    ~H"""
    <div class="swai-model-card">
      <div class="swai-model-card-header">
        <img class="h-48 w-full object-cover opacity-80"
        src={"#{@training_ground.image_url}"} alt={"#{@training_ground.id}"}
        >
      </div>
      <div class="swai-model-card-body">
        <p class="text-sm font-medium text-lt-edit-gradient">
          <%= @training_ground.theme %>
        </p>
        <a href="#{Routes.training_ground_path(@socket, :show, @training_ground)}"
        class="block mt-2 text-xl font-semibold text-lt-section-header">
          <%= @training_ground.name %>
        </a>
        <p class="mt-3 text-base text-white">
          <%= @training_ground.description %>
        </p>
        <div class="mt-6 flex items-center">
          <a href="#{Routes.training_ground_path(@socket, :show, @training_ground)}"
          class="text-lt-edit-gradient hover:text-lt-section-header">
            View
          </a>
        </div>
      </div>
    </div>
    """
  end
end
