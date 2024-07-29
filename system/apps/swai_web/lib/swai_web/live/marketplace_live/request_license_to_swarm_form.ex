defmodule SwaiWeb.MarketplaceLive.RequestLicenseToSwarmForm do
  use SwaiWeb, :live_component

  alias Schema.SwarmTraining,
    as: SwarmTraining

  alias Edge.Init, as: EdgeInit
  alias TrainSwarmProc, as: TrainSwarmProc
  alias Schema.Biotope, as: Biotope

  require Logger

  @form_data "swarm_training"

  @user_id "user_id"
  @biotope_id "biotope_id"
  @biotope_name "biotope_name"
  @swarm_id "swarm_id"
  @agg_id "agg_id"
  @id "id"
  @scape_id "scape_id"

  @impl true
  def update(assigns, socket) do
    map = %{
      @id => "temporary_id",
      @user_id => assigns.current_user.id,
      @biotope_id => assigns.biotope.id,
      @biotope_name => assigns.biotope.name,
      @scape_id => assigns.biotope.scape_id
    }

    lr_changes =
      %SwarmTraining{}
      |> TrainSwarmProc.change_swarm_training(map)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(trigger_submit: false)
      |> assign(check_errors: true)
      |> assign_form(lr_changes)
    }
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: @form_data)
    # Logger.alert("ASSIGNING FORM #{inspect(form)}")

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
  def handle_event("submit_lr", %{@form_data => source} = _license_params, socket) do
    agg_id = UUID.uuid4()

    enriched_params =
      source
      |> Map.put(@agg_id, agg_id)
      |> Map.put(@id, agg_id)
      |> Map.put(@swarm_id, UUID.uuid4())
      |> Map.put(@user_id, socket.assigns.current_user.id)
      |> Map.put(@biotope_id, socket.assigns.biotope.id)
      |> Map.put(@biotope_name, socket.assigns.biotope.name)
      |> Map.put(@scape_id, socket.assigns.biotope.scape_id)



    case TrainSwarmProc.initialize(enriched_params) do
      :ok ->
        notify_parent({:swarm_training_submitted, enriched_params})

        {:noreply, socket}

      _msg ->
        {:noreply, socket}
    end

    {:noreply, socket}
  end

  ################## VALIDATION ##################
  @impl true
  def handle_event("validate_lr", %{@form_data => form_data}, socket) do
    changeset =
      socket.assigns.swarm_training
      |> TrainSwarmProc.change_swarm_training(form_data)
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
    {
      :noreply,
      socket
      |> assign(:show_init_swarm_modal, false)
    }
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
          <%= if @current_user.budget - @form[:cost_in_tokens].value < 0  do %>
            <strong class="text-red-500">The cost of a license for this configuration is <%= @form[:cost_in_tokens].value %>👾</strong>.
          <% else %>
            <strong class="text-green-500">The cost of a license for this configuration is <%= @form[:cost_in_tokens].value %>👾</strong>.
          <% end %>
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
         <.input
            class="form-control"
            label="Swarm Name"
            type="text"
            field={@form[:swarm_name]}
            required
          />

          <.input
            class="form-control"
            label="Swarm Size"
            type="number"
            pattern="\\d*"
            step="1"
            field={@form[:swarm_size]}
            required
            readonly
           />
          <.input
            class="form-control"
            label="Swarming Time in Minutes"
            type="number"
            pattern="\\d*"
            step="1"
            field={@form[:generation_epoch_in_minutes]}
            required
            readonly
          />
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
