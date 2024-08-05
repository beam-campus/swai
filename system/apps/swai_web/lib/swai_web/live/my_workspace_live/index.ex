defmodule SwaiWeb.MyWorkspaceLive.Index do
  @moduledoc """
  The live view for the workspace index page.
  """
  use SwaiWeb, :live_view

  alias Edges.Service, as: Edges
  alias Phoenix.PubSub, as: PubSub
  alias TrainSwarmProc.Facts, as: Facts
  alias SwarmLicenses.Service, as: SwarmLicenses

  alias TrainSwarmProc.Initialize.PayloadV1, as: InitPayload
  alias TrainSwarmProc.Configure.PayloadV1, as: ConfigPayload

  alias Schema.SwarmLicense, as: SwarmLicense

  @swarm_licenses_cache_updated_v1 Facts.cache_updated_v1()
  @user_id "user_id"

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    case connected?(socket) do
      true ->
        # trainings = Workspace.get_swarm_licenses_by_user_id(current_user.id)
        trainings = SwarmLicenses.get_all_for_user(current_user.id)

        Swai.PubSub
        |> PubSub.subscribe(@swarm_licenses_cache_updated_v1)

        {
          :ok,
          socket
          |> assign(
            page_title: "My Workspace",
            edges: Edges.get_all(),
            now: DateTime.utc_now(),
            swarm_licenses: trainings
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
  def handle_info(
        {_, payload, %{@user_id => the_user} = meta},
        socket
      ) do
    Logger.debug("Swarm Trainings Cache Updated - #{inspect(payload)} - #{inspect(meta)}")

    if the_user == socket.assigns.current_user.id do
      trainings = SwarmLicense.get_all_for_user(socket.assigns.current_user.id)
      {:noreply, assign(socket, swarm_licenses: trainings)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(msg, socket) do
    Logger.warn("Unhandled message: #{inspect(msg)}")
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="workspace" class="flex flex-col my-5">
      <section class="py-3">
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
    </div>
    """
  end
end
