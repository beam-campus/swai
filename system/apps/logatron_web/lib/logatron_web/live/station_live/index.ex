defmodule LogatronWeb.StationLive.Index do
  use LogatronWeb, :live_view

  alias Logatron.Stations
  alias Logatron.Stations.Station

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :stations, Stations.list_stations())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Station")
    |> assign(:station, Stations.get_station!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Station")
    |> assign(:station, %Station{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Stations")
    |> assign(:station, nil)
  end

  @impl true
  def handle_info({Web.StationLive.FormComponent, {:saved, station}}, socket) do
    {:noreply, stream_insert(socket, :stations, station)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    station = Stations.get_station!(id)
    {:ok, _} = Stations.delete_station(station)

    {:noreply, stream_delete(socket, :stations, station)}
  end
end
