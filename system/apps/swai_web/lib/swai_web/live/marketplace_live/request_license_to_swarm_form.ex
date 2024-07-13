defmodule SwaiWeb.MarketplaceLive.RequestLicenseToSwarmForm do
  use SwaiWeb, :live_component

  alias TrainSwarmProc.Initialize.Cmd, as: RequestLicense
  alias Edge.Init, as: EdgeInit
  alias TrainSwarmProc, as: TrainSwarmProc
  alias Schema.Biotope, as: Biotope

  require Logger

  @impl true
  def update(assigns, socket) do
    map = %{
      "user_id" => assigns.current_user.id,
      "biotope_id" => assigns.biotope.id
    }

    lr_changes =
      %RequestLicense{}
      |> TrainSwarmProc.change_license_request(map)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(trigger_submit: false)
      |> assign(check_errors: true)
      |> assign_form(lr_changes)
    }
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "license_request")
    Logger.alert("ASSIGNING FORM #{inspect(form)}")
    if changeset.valid? do
      socket
      |> assign(form: form, check_errors: false)
    else
      socket
      |> assign(form: form)
    end
  end

  ############## SUBMISSIONS ####################
  @impl true
  def handle_event("submit_lr", params, socket) do
    Logger.alert("RequestLicenseToSwarmForm.handle_event #{inspect(params)}")

    {:noreply, socket}
  end

  ################## VALIDATION ##################
  @impl true
  def handle_event("validate_lr", %{"license_request" => license_request_params}, socket) do
    Logger.alert("VALIDATING #{inspect(license_request_params)}")

    changeset =
      socket.assigns.license_request
      |> TrainSwarmProc.change_license_request(license_request_params)
      |> Map.put(:action, :validate)

    {
      :noreply,
      socket
      |> assign_form(changeset)
    }
  end

  ################## CLOSING ##################
  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, socket |> assign(:show_init_swarm_modal, false)}
  end

  ################## RENDERING ##################
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
          <%= @title %>
          <:subtitle>
          A 'License to Swarm' represents a reservation for a slot to evolve your swarm.
          It is automatically activated when your budget (<strong><%= @current_user.budget %>👾</strong>) allows it. <br/>
          The cost of a license for this configuration is <strong><%= @form[:cost_in_tokens].value %>👾</strong>.
          </:subtitle>
      </.header>
      <.simple_form
        for={@form}
        class="modal-content"
        id="license_request_form"
        phx-target={@myself}
        phx-submit="submit_lr"
        phx-change="validate_lr"
        phx-trigger-action={@trigger_submit}
        method="post"
      >

      <div class="form-group">
          <.input
            class="form-control"
            label="Budget required for this License"
            type="number"
            field={@form[:cost_in_tokens]}
            pattern="\\d*"
            step="1"
            readonly
          />
          <.input
            class="form-control"
            label="Swarm Size (drones per swarm)"
            type="number"
            pattern="\\d*"
            step="1"
            field={@form[:swarm_size]}
            required
           />
          <.input
            class="form-control"
            label="Neural Depth (number of layers in a drone's neural network)"
            type="number"
            pattern="\\d*"
            step="1"
            field={@form[:drone_depth]}
            required
          />
          <.input
            class="form-control"
            label="Number of Generations"
            type="number"
            pattern="\\d*"
            step="1"
            field={@form[:nbr_of_generations]}
            required
          />
          <.input
            class="form-control"
            label="Generation Epoch (lifetime of a generation in minutes)"
            type="number"
            pattern="\\d*"
            step="1"
            field={@form[:generation_epoch_in_minutes]}
            required
          />
          <.input
            class="form-control"
            label="Pick Best (Number of Drones to select as parents for the next generation)"
            type="number"
            pattern="\\d*"
            step="1"
            field={@form[:select_best_count]}
            required
          />
        </div>

        <%!-- <div class="form-group">
          <.input
            class="form-control"
            label="Budget required for this License"
            type="number"
            field={@form[:cost_in_tokens]}
            pattern="\\d*"
            step="1"
            readonly
          />
          <.input
            class="form-control"
            label="Swarm Size (drones per swarm)"
            type="number"
            pattern="\\d*"
            step="1"
            field={@form[:swarm_size]}
            phx-change="validate_lr"
            required
           />
          <.input
            class="form-control"
            label="Neural Depth (number of layers in a drone's neural network)"
            type="number"
            pattern="\\d*"
            step="1"
            field={@form[:drone_depth]}
            phx-change="validate_lr"
            required
          />
          <.input
            class="form-control"
            label="Number of Generations"
            type="number"
            pattern="\\d*"
            step="1"
            field={@form[:nbr_of_generations]}
            phx-change="validate_lr"
            required
          />
          <.input
            class="form-control"
            label="Generation Epoch (lifetime of a generation in minutes)"
            type="number"
            pattern="\\d*"
            step="1"
            field={@form[:generation_epoch_in_minutes]}
            phx-change="validate_lr"
            required
          />
          <.input
            class="form-control"
            label="Pick Best (Number of Drones to select as parents for the next generation)"
            type="number"
            pattern="\\d*"
            step="1"
            field={@form[:select_best_count]}
            phx-change="validate_lr"
            required
          />
        </div> --%>

        <div class="mt-3">
        <.button
          phx-disable-with="Requesting License..."
        >Submit your License Request</.button>
        </div>
      </.simple_form>
      <button class="modal-close is-large" aria-label="close" phx-click="close_modal"></button>
    </div>
    """
  end
end
