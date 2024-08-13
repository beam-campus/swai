defmodule SwaiWeb.EdgeBrowser.WorldMap do
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
      <svg 
        id="edges-world-map-svg"         
        phx-hook="TheMap" 
        data-edges={Jason.encode!(@edges)}         
      />
    """
  end
  
end