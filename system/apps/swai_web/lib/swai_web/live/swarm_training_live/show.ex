defmodule SwaiWeb.SwarmTrainingLive.Show do
  use SwaiWeb, :live_view

  alias Swai.Workspace

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:swarm_training, Workspace.get_swarm_training!(id))}
  end

  defp page_title(:show), do: "Show Swarm training"
  defp page_title(:edit), do: "Edit Swarm training"
end
