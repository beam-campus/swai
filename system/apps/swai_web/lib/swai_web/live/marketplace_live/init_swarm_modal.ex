defmodule SwaiWeb.MarketplaceLive.InitSwarmModal do
  use SwaiWeb, :live_component

  alias TrainSwarm.Initialize.Cmd, as: InitializeSwarmTraining
  alias Edge.Init, as: EdgeInit

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:initialize_swarm_training,
     InitializeSwarmTraining.from_map(
      %InitializeSwarmTraining{
        user: socket.assigns.current_user,
        biotope: socket.assigns.current_biotope,
        edge: EdgeInit.enriched()
       })
      )
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="init-swarm-modal" class="modal z-100">
      <div class="modal-background"></div>
      <div class="modal-content">
        <form phx-submit="submit_swarm_init">
          <!-- Add more fields as necessary -->
          <div class="field">
            <div class="control">
              <button type="submit" class="button is-link">Submit</button>
            </div>
          </div>
        </form>
      </div>
      <button class="modal-close is-large" aria-label="close" phx-click="close_modal"></button>
    </div>
    """
  end

  def handle_event("submit_swarm_init", params, socket) do
    {:noreply, socket}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, socket |> assign(:show_init_swarm_modal, false)}
  end
end
