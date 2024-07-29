defmodule SwaiWeb.SwarmTrainingLive.Index do
  use SwaiWeb, :live_view

  alias Swai.Workspace
  alias Schema.SwarmTraining

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :swarm_trainings, Workspace.list_swarm_trainings())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Swarm training")
    |> assign(:swarm_training, Workspace.get_swarm_training!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Swarm training")
    |> assign(:swarm_training, %SwarmTraining{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Swarm trainings")
    |> assign(:swarm_training, nil)
  end

  @impl true
  def handle_info({SwaiWeb.SwarmTrainingLive.FormComponent, {:saved, swarm_training}}, socket) do
    {:noreply, stream_insert(socket, :swarm_trainings, swarm_training)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    swarm_training = Workspace.get_swarm_training!(id)
    {:ok, _} = Workspace.delete_swarm_training(swarm_training)

    {:noreply, stream_delete(socket, :swarm_trainings, swarm_training)}
  end
end
