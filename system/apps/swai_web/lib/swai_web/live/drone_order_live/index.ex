defmodule SwaiWeb.DroneOrderLive.Index do
  use SwaiWeb, :live_view

  alias Swai.Marketplace
  alias Schema.DroneOrder

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :drone_orders, Marketplace.list_drone_orders())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Drone order")
    |> assign(:drone_order, Marketplace.get_drone_order!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Drone order")
    |> assign(:drone_order, %DroneOrder{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Drone orders")
    |> assign(:drone_order, nil)
  end

  @impl true
  def handle_info({SwaiWeb.DroneOrderLive.FormComponent, {:saved, drone_order}}, socket) do
    {:noreply, stream_insert(socket, :drone_orders, drone_order)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    drone_order = Marketplace.get_drone_order!(id)
    {:ok, _} = Marketplace.delete_drone_order(drone_order)

    {:noreply, stream_delete(socket, :drone_orders, drone_order)}
  end
end
