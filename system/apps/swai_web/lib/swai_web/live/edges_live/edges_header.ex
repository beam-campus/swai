defmodule SwaiWeb.EdgesLive.EdgesHeader do
  use SwaiWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-2">
      <div class="flex flex-wrap justify-start gap-2">
      <p>A global overview of the Macula Mesh</p>
      </div>
    </div>
    """
  end

end
