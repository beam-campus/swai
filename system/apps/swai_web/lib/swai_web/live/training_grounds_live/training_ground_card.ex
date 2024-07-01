defmodule SwaiWeb.TrainingGroundsLive.TrainingGroundCard do
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
    <div class="flex flex-col bg-white shadow-lg rounded-lg overflow-hidden">
      <div class="flex-shrink-0">
        <img class="h-48 w-full object-cover"
        src={"#{@training_ground.image_url}"} alt={"#{@training_ground.id}"}
        >

      </div>
      <div class="flex-1 bg-white p-6 flex flex-col justify-between">
        <div class="flex-1">
          <p class="text-sm font-medium text-indigo-600">
            <%= @training_ground.theme %>
          </p>
          <a href="#{Routes.training_ground_path(@socket, :show, @training_ground)}"
          class="block mt-2  text-xl font-semibold text-gray-900">
            <%= @training_ground.name %>
          </a>
          <p class="mt-3 text-base text-gray-500">
            <%= @training_ground.description %>
          </p>
        </div>
        <div class="mt-6 flex items-center">
          <div class="flex-shrink-0">
            <a href="#{Routes.training_ground_path(@socket, :show, @training_ground)}"
            class="text-indigo-600 hover:text-indigo-900">
              View
            </a>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
