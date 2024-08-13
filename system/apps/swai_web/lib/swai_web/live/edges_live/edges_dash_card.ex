defmodule SwaiWeb.EdgesLive.EdgesDashCard do
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
    <div class="flex flex-col w-full h-full ml-4">
      <div class="flex flex-row w-full h-12 bg-gray-800 rounded-lg shadow-lg">
        <div class="flex flex-col w-1/2 h-full justify-center items-center">
          <div class="text-white">Edges</div>
        </div>
      </div>
    </div>
    """
  end

  
end