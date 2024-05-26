defmodule LogatronWeb.Born2DiedsLive.Born2DiedsCard do
  use LogatronWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end


end
