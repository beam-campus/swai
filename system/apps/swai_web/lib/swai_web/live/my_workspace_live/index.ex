defmodule SwaiWeb.MyWorkspaceLive.Index do
  use SwaiWeb, :live_view

  @moduledoc """
  The live view for the workspace index page.
  """

  alias Workspaces.Service, as: Workspaces
  alias Edges.Service, as: Edges
  alias MngWorkspace.Root, as: Workspace

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign(
           workspace: Workspaces.get_workspace(current_user.id),
           edges: Edges.get_all(),
           now: DateTime.utc_now()
         )}

      false ->
        {:ok,
         socket
         |> assign(
           workspace: Workspaces.get_workspace(current_user.id),
           edges: Edges.get_all(),
           now: DateTime.utc_now()
         )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div  id="workspace"  class="flex flex-col">
    </div>
    """
  end
end
