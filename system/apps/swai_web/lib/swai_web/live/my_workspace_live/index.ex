defmodule SwaiWeb.MyWorkspaceLive.Index do
  @moduledoc """
  The live view for the workspace index page.
  """
  alias Swai.Accounts
  use SwaiWeb, :live_view

  alias Edges.Service, as: Edges
  alias Phoenix.PubSub, as: PubSub
  alias TrainSwarmProc.Facts, as: TrainSwarmProcFacts
  alias SwarmLicenses.Service, as: Licenses


  alias Schema.SwarmLicense, as: SwarmLicense

  @license_cache_updated TrainSwarmProcFacts.cache_updated_v1()

  # @license_cache_facts TrainSwarmProcFacts.cache_facts()

  require Logger


  @impl true
  def mount(_params, _session, socket) do

    current_user = socket.assigns.current_user

    case connected?(socket) do
      true ->
        # trainings = Workspace.get_swarm_licenses_by_user_id(current_user.id)

        Swai.PubSub
        |> PubSub.subscribe(@license_cache_updated)

        {
          :ok,
          socket
          |> assign(
            page_title: "My Workspace",
            edges: Edges.get_all(),
            now: DateTime.utc_now(),
            swarm_licenses: Licenses.get_all_for_user(current_user.id)
          )
        }

      false ->
        {:ok,
         socket
         |> assign(
           page_title: "My Workspace",
           edges: [],
           now: DateTime.utc_now(),
           swarm_licenses: []
         )}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {
      :noreply,
      socket
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Workspace")
  end

  @impl true
  def handle_info({:license, _evt, %SwarmLicense{user_id: the_user}}, socket) do
    if the_user == socket.assigns.current_user.id do
      new_user = Accounts.get_user!(the_user)
      licenses = Licenses.get_all_for_user(socket.assigns.current_user.id)
      {
        :noreply,
        socket
        |> assign(
          current_user: new_user,
          swarm_licenses: licenses
        )
      }
    else
      {:noreply, socket}
    end
  end

########################### UNHANDLED MESSAGES ############################
  @impl true
  def handle_info({:license, _evt, _license}, socket) do
    licenses = Licenses.get_all_for_user(socket.assigns.current_user.id)
    {
      :noreply,
      socket
      |> assign(
        swarm_licenses: licenses
        )
    }

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="workspace-view" class="flex flex-col h-full">
      <section class="mt-11">
        <.live_component
          id="active-swarms-section"
          current_user={@current_user}
          live_action={@live_action}
          module={SwaiWeb.MyWorkspaceLive.SwarmLicensesSection}
          edges={@edges}
          swarm_licenses={@swarm_licenses}
          now={@now}
          section_title="My Swarm Licenses"
          section_description="This is a list of all the Swarm Licenses you have created."
        />
      </section>
      <section id="dummy-section" class="pt-15" style="height: 100px;">
       <div class="flex justify-center items-center" style="height: 150px;">
         <p class="text-lg text-gray-500"></p>
         </div>
      </section>
    </div>
    """
  end
end
