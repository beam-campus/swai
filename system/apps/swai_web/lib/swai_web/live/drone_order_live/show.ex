defmodule SwaiWeb.DroneOrderLive.Show do
  use SwaiWeb, :live_view

  alias Swai.Marketplace

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:drone_order, Marketplace.get_drone_order!(id))}
  end

  defp page_title(:show), do: "Show Drone order"
  defp page_title(:edit), do: "Edit Drone order"
end
