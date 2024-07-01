defmodule Workspaces.Service do
  @moduledoc """
  The service module for the workspace.
  """
  use GenServer

  alias MngWorkspace.Root, as: Workspace
  require Logger
  require Colors

  ############## API ##############
  def get_workspace(user_id) do
    case :workspaces_cache
         |> Cachex.get!(user_id) do
      nil ->
        init_workspace(user_id)

      resp ->
        resp
    end
  end

  def init_workspace(user_id) do
    ws = %Workspace{user_id: user_id}

    :workspaces_cache
    |> Cachex.put!(user_id, ws)

    ws
  end

  ################## CALLBACKS ###############
  @impl true
  def init(_args) do
    Logger.debug("Starting Workspace service #{Colors.workspace_theme(self())}")
    {:ok, %{}}
  end

  ################# handle_cast #################
  @impl true
  def handle_cast({:add_workspace, user_id}, state) do
    workspace = %Workspace{
      user_id: user_id
    }

    :workspaces_cache
    |> Cachex.put!(user_id, workspace)

    {:noreply, state}
  end

  ################# handle_call #################
  @impl true
  def handle_call({:get_workspace, user_id}, _from, state) do
  end

  ################# PLUMBING #################
  def child_spec(_args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end
end
