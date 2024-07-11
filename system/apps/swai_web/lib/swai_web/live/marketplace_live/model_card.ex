defmodule SwaiWeb.MarketplaceLive.ModelCard do
  use SwaiWeb, :live_component

  alias TrainSwarmProc.Initialize.Cmd, as: RequestLicense

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={"section-card " <> active_class(@biotope.is_active?)}>
      <div class="section-card-header">
        <img class="h-24 w-full object-cover opacity-80 rounded radius-5"
        src={"#{@biotope.image_url}"} alt={"#{@biotope.id}"}>
      </div>
      <div class="section-card-body">
        <div>
          <p class="text-sm font-medium uppercase">
            <%= @biotope.theme %>
          </p>
          <a href="#{Routes.biotope_path(@socket, :show, @biotope)}"
          class="block mt-2 text-xl font-semibold text-lt-section-header">
            <%= @biotope.name %>
          </a>
          <p class="mt-3 text-base text-white">
            <%= @biotope.description %>
          </p>
        </div>
        <div class="button-row mt-4 flex justify-between">
        <%= if @biotope.is_active? do %>
          <div>

            <button class="btn-view">View</button>
            <%!-- <.link patch={~p"/marketplace/request_license"} phx-click="request-license-to-swarm" phx-value-biotope-id={@biotope.id}> --%>

              <.link patch={~p"/marketplace/start_swarm"}>
                <button>Swarm!</button>
              </.link>

            <%!--
            Train a Swarm
            </.link> --%>
            <button class="btn-dashboard">Dashboard</button>

            <.modal
              :if={@live_action in [:start_swarm, :request_license, :new]}
              id="request-license-modal-dialog"
              show
              on_cancel={JS.patch(~p"/marketplace")}
              >
              <.live_component
                module={SwaiWeb.MarketplaceLive.RequestLicenseToSwarmForm}
                id={"request-license-modal-card-" <> @biotope.id}
                title={"Request a License to Swarm"}
                action={@live_action}
                selected_biotope={@biotope}
                current_user={@current_user}
                patch={~p"/marketplace"}
                edges={@edges}
                request_license={%RequestLicense{}}
              />
            </.modal>


            </div>


        <% else %>


            <.button class="btn-view">View</.button>
            <.button class="btn-sponsor">Sponsor this Model</.button>


        <% end %>
        </div>
      </div>

    </div>



    """
  end

  defp active_class(true), do: "active-biotope"
  defp active_class(false), do: "inactive-biotope"



end
