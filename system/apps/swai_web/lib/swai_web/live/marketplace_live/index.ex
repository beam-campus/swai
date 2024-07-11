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
        active_models = Enum.filter(biotopes, & &1.is_active?)
        inactive_models = Enum.reject(biotopes, & &1.is_active?)

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
            current_biotope: nil,
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
           current_biotope: nil,
           live_action: :index
         )}
    end
  end

  # @impl true
  # def handle_event("request-license-to-swarm", params, socket) do
  #   Logger.alert("Requesting license to swarm for biotope #{inspect(params)}")

  #   current_biotope =
  #     socket.assigns.active_models
  #     |> Enum.find(fn it -> it.id == params["biotope-id"] end)

  #   current_user = socket.assigns.current_user

  #   Logger.alert(
  #     "Creating Request_license for biotope #{current_biotope.id} for user #{current_user.id}"
  #   )

  #   request_license =
  #     RequestLicense.changeset_from_user_and_biotope(current_user, current_biotope)

  #   {:noreply,
  #    socket
  #    |> assign(
  #      show_init_swarm_modal: true,
  #      request_license:
  #        RequestLicense.changeset_from_user_and_biotope(current_user, current_biotope),
  #      current_biotope: current_biotope
  #    )}
  # end

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
    |> assign(:page_title, "Listing Born 2 dieds")
    |> assign(:request_license, nil)
    |> assign(:current_biotope, nil)
  end

  defp apply_action(socket, :start_swarm, params) do

    current_biotope =
      socket.assigns.active_models
      |> Enum.find(fn it -> it.id == params["biotope-id"] end)

    current_user = socket.assigns.current_user

    socket
    |> assign(
      page_title: "Request a License to Swarm",
      # request_license: %RequestLicense{},
      current_biotope: current_biotope
    )
  end

  # @impl true
  # def handle_params(params, _url, socket) do
  #   Logger.alert("Handling params #{inspect(params)}")

  #   case Map.get(params, "biotope-id") do
  #     nil ->
  #       {:noreply, socket |> assign(show_init_swarm_modal: false)}

  #     biotope_id ->
  #       current_biotope =
  #         socket.assigns.active_models
  #         |> Enum.find(fn it -> it.id == biotope_id end)

  #       current_user = socket.assigns.current_user

  #       request_license =
  #         RequestLicense.changeset_from_user_and_biotope(current_user, current_biotope)

  #       {:noreply,
  #        socket
  #        |> assign(
  #          show_init_swarm_modal: false,
  #          current_biotope: current_biotope,
  #          request_license: request_license
  #        )}
  #   end
  # end

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

        <%!-- <.modal
          :if={@live_action in [:start_swarm, :request_license, :new]}
          id="request-license-modal"
          show
          on_cancel={JS.patch(~p"/marketplace")}
          >
          <.live_component
            module={SwaiWeb.MarketplaceLive.RequestLicenseToSwarmForm}
            id={"request-license-modal" <> @current_user.id}
            title={"Request a License to Swarm"}
            action={@live_action}
            selected_biotope={@current_biotope}
            active_edges={@edges}
            current_user={@current_user}
            patch={~p"/marketplace"}
            request_license={@request_license}
          />
        </.modal>
    --%>
    """
  end
end
