defmodule SwaiWeb.MarketplaceLive.Index do
  use SwaiWeb, :live_view

  @moduledoc """
  The live view for the training grounds index page.
  """

  alias Edges.Service, as: Edges
  alias Swai.Biotopes, as: Biotopes
  alias TrainSwarmProc.Initialize.Cmd, as: RequestLicense
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    case connected?(socket) do
      true ->
        biotopes = Biotopes.list_biotopes()
        active_models = biotopes |> Enum.filter(& &1.is_active?)
        inactive_models = biotopes |> Enum.reject(& &1.is_active?)

        {
          :ok,
          socket
          |> assign(
            edges: Edges.get_all(),
            active_models: active_models,
            inactive_models: inactive_models,
            now: DateTime.utc_now(),
            page_title: "Marketplace",
            show_init_swarm_modal: false,
            biotope: nil,
            live_action: :index
          )
        }

      false ->
        {:ok,
         socket
         |> assign(
           edges: Edges.get_all(),
           active_models: [],
           inactive_models: [],
           now: DateTime.utc_now(),
           page_title: "Marketplace",
           show_init_swarm_modal: false,
           biotope: nil,
           live_action: :index
         )}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    Logger.alert("Handling params #{inspect(params)}")
    {
      :noreply,
      socket
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Born 2 dieds")
    |> assign(:license_request, nil)
    |> assign(:biotope, nil)
  end

  defp apply_action(socket, :start_swarm, params) do
    Logger.alert("Handling params for :start_swarm #{inspect(params)}")


    current_biotope =
      socket.assigns.active_models
      |> Enum.find(fn it -> it.id == params["biotope_id"] end)

    current_user = socket.assigns.current_user

    socket
    |> assign(
      page_title: "Request a License to Swarm",
      # request_license: %RequestLicense{},
      biotope: current_biotope
    )
  end

  @impl true



  @impl true
  def render(assigns) do
    ~H"""
    <div id="marketplace-view" class="flex flex-col my-5">
      <section class="py-3">
        <.live_component
            id="active-models-section"
            current_user={@current_user}
            live_action={@live_action}
            module={SwaiWeb.MarketplaceLive.ModelsSection}
            edges={@edges}
            biotopes={@active_models}
            now={@now}
            section_title="Available Ecosystems"
            section_description="
            Please do keep in mind that right now, only one swarm can be trained on the free plan."
        />
      </section>
      <section class="py-3">
        <.live_component
          id="inactive-models-section"
          current_user={@current_user}
          live_action={@live_action}
          module={SwaiWeb.MarketplaceLive.ModelsSection}
          edges={@edges}
          biotopes={@inactive_models}
          now={@now}
          section_title="Coming soon..."
          section_description="Do you want to see these models to become available for your research or entertainment?
          Then do consider supporting our efforts by buying us a coffee or by becoming part of a community that
          is dedicated to this different form of AI!"
        />
      </section>
    </div>

    <.modal
      :if={@live_action in [:start_swarm, :request_license, :new]}
      id="request-license-modal-dialog"
      show
      on_cancel={JS.patch(~p"/marketplace")}
      >
      <.live_component
        module={SwaiWeb.MarketplaceLive.RequestLicenseToSwarmForm}
        id={"request-license-modal-dialog"}
        title={"Request a License to Swarm for: #{@biotope.name}"}
        action={@live_action}
        biotope={@biotope}
        current_user={@current_user}
        patch={~p"/marketplace"}
        edges={@edges}
        license_request={%RequestLicense{
          user_id: @current_user.id,
          biotope_id: @biotope.id,
        }}
    />
    </.modal>


    """
  end
end
