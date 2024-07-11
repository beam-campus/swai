defmodule SwaiWeb.MarketplaceLive.RequestLicenseToSwarmForm do
  use SwaiWeb, :live_component

  alias TrainSwarmProc.Initialize.Cmd, as: RequestLicense
  alias Edge.Init, as: EdgeInit
  alias TrainSwarmProc, as: TrainSwarmProc

  require Logger

  @impl true
  def update(assigns, socket) do
    license_request_changes =
      TrainSwarmProc.change_license_request(
        %RequestLicense{},
        assigns.current_user,
        assigns.selected_biotope
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(license_request_changes))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
    <.header>
        <%= @title %>
        <:subtitle>Use this form to manage animal records in your database.</:subtitle>
    </.header>

      <h1>Request a License to Swarm for <%= @selected_biotope.name %></h1>
          <.form phx-submit="request_license" class="modal-content">
            <input type="hidden" name="current_user" value={@current_user.id} />
            <div class="form-group">
              <.label for="active_edge">Swarm Size</.label>
              <.input
                type="number"
                name="active_edge"
                class="form-control"
                value={@request_license.swarm_size}
                id="drone_size_input" />

            </div>
            <.button type="submit" class="btn btn-primary">Request License</.button>
          </.form>
        <button class="modal-close is-large" aria-label="close" phx-click="close_modal"></button>
      </div>
    """
  end

  def handle_event("submit_swarm_init", params, socket) do
    Logger.alert("RequestLicenseToSwarmForm.handle_event #{inspect(params)}")
    {:noreply, socket}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, socket |> assign(:show_init_swarm_modal, false)}
  end
end
