defmodule SwaiWeb.MarketplaceLive.RequestLicenseToSwarmForm do
  use SwaiWeb, :live_component

  alias TrainSwarmProc.Initialize.Cmd, as: RequestLicense
  alias Edge.Init, as: EdgeInit
  alias TrainSwarmProc, as: TrainSwarmProc
  alias Schema.Biotope, as: Biotope

  require Logger

  @impl true
  def update(assigns, socket) do
    license_request_changes =
      TrainSwarmProc.change_license_request(
        %RequestLicense{},
        assigns.current_user,
        assigns.biotope
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
          <:subtitle>
          A 'License to Swarm' represents a reservation for a slot to evolve your swarm.
          It is automatically activated when your budget (<strong><%= @current_user.budget %>👾</strong>) allows it. The license you want costs <strong><%= @request_license.budget_required %></strong>👾.
          </:subtitle>
      </.header>
      <.form phx-submit="request_license" class="modal-content">
        <input type="hidden" name="current_user" value={@current_user.id} />
        <div class="form-group">

          <.label for="active_edge">Swarm Size (drones per swarm) </.label>
          <.input
            type="number"
            name="active_edge"
            class="form-control"
            value={@request_license.swarm_size}
            id="swarm_size_input" />

          <.label for="active_edge">Neural Depth (number of layers in a drone's neural network)</.label>
          <.input
            type="number"
            name="active_edge"
            class="form-control"
            value={@request_license.drone_depth}
            id="generations_input" />

          <.label for="active_edge">Number of Generations</.label>
          <.input
            type="number"
            name="active_edge"
            class="form-control"
            value={@request_license.nbr_of_generations}
            id="generations_input" />



          <.label for="active_edge">Generation Epoch (min)</.label>
          <.input
            type="number"
            name="active_edge"
            class="form-control"
            value={@request_license.generation_epoch_in_minutes}
            id="generation_epoch_input" />

          <.label for="active_edge">Pick Best</.label>
          <.input
            type="number"
            name="active_edge"
            class="form-control"
            value={@request_license.select_best_count}
            id="select_best_input" />

        </div>
        <div class="mt-3">
        <.button type="submit"  class="btn btn-primary">Submit your License Request</.button>
        </div>
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
