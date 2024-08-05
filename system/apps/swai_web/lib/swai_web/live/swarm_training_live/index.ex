defmodule SwaiWeb.SwarmLicenseLive.Index do
  use SwaiWeb, :live_view

  alias Swai.Workspace
  alias Schema.SwarmLicense

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :swarm_licenses, Workspace.list_swarm_licenses())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Swarm training")
    |> assign(:swarm_license, Workspace.get_swarm_license!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Swarm training")
    |> assign(:swarm_license, %SwarmLicense{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Swarm trainings")
    |> assign(:swarm_license, nil)
  end

  @impl true
  def handle_info({SwaiWeb.SwarmLicenseLive.FormComponent, {:saved, swarm_license}}, socket) do
    {:noreply, stream_insert(socket, :swarm_licenses, swarm_license)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    swarm_license = Workspace.get_swarm_license!(id)
    {:ok, _} = Workspace.delete_swarm_license(swarm_license)

    {:noreply, stream_delete(socket, :swarm_licenses, swarm_license)}
  end
end
