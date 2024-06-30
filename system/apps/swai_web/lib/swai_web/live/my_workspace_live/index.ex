defmodule SwaiWeb.MyWorkspaceLive.Index do
  use SwaiWeb, :live_view

  @moduledoc """
  The live view for the workspace index page.
  """

  @impl true
  def mount(_params, _session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign(:workspace, Swai.Workspace.get!(1))}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_event("update_workspace", %{"workspace" => workspace_params}, socket) do
    workspace = Swai.Workspace.get!(1)

    case Swai.Workspace.update(workspace, workspace_params) do
      {:ok, _workspace} ->
        {:noreply, socket |> put_flash(:info, "Workspace updated successfully.")}

      {:error, changeset} ->
        {:noreply, assign(socket, :workspace_form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <h1 class="text-2xl font-semibold">Workspace</h1>

    </div>
    """
  end
end
