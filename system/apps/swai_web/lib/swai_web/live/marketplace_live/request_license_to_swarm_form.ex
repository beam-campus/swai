defmodule SwaiWeb.MarketplaceLive.RequestLicenseToSwarmForm do
  use SwaiWeb, :live_component

  alias Schema.SwarmLicense,
    as: SwarmLicense

  alias TrainSwarmProc, as: TrainSwarmProc
  alias Schema.Swarm, as: Swarm

  require Logger

  @form_data "swarm_license"

  @user_id "user_id"

  @biotope_id "biotope_id"
  @biotope_name "biotope_name"

  @agg_id "agg_id"
  @license_id "license_id"

  @algorithm_id "algorithm_id"
  @algorithm_acronym "algorithm_acronym"
  @algorithm_name "algorithm_name"

  @swarm_name "swarm_name"
  @swarm_id "swarm_id"
  @available_tokens "available_tokens"

  @impl true
  def update(assigns, socket) do
    prefix = "#{assigns.current_user.user_alias}_#{assigns.biotope.name}"

    map = %{
      @license_id => "temporary_id",
      @user_id => assigns.current_user.id,
      @biotope_id => assigns.biotope.id,
      @biotope_name => assigns.biotope.name,
      @algorithm_id => assigns.biotope.algorithm_id,
      @algorithm_acronym => assigns.biotope.algorithm_acronym,
      @algorithm_name => assigns.biotope.algorithm_name,
      @swarm_id => UUID.uuid4(),
      @swarm_name => Swarm.generate_swarm_name(prefix, 2),
      @available_tokens => assigns.current_user.budget
    }

    lr_changes =
      %SwarmLicense{}
      |> TrainSwarmProc.change_swarm_license(map)

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
    # Logger.debug("ASSIGNING FORM #{inspect(form)}")

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
      |> Map.put(@license_id, agg_id)
      |> Map.put(@swarm_id, UUID.uuid4())
      |> Map.put(@user_id, socket.assigns.current_user.id)
      |> Map.put(@biotope_id, socket.assigns.biotope.id)
      |> Map.put(@biotope_name, socket.assigns.biotope.name)
      |> Map.put(@algorithm_id, socket.assigns.biotope.algorithm_id)
      |> Map.put(@algorithm_acronym, socket.assigns.biotope.algorithm_acronym)
      |> Map.put(@algorithm_name, socket.assigns.biotope.algorithm_name)
      |> Map.put(@available_tokens, socket.assigns.current_user.budget)

    case TrainSwarmProc.initialize(enriched_params) do
      :ok ->
        notify_parent({:swarm_license_submitted, enriched_params})

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
      socket.assigns.swarm_license
      |> TrainSwarmProc.change_swarm_license(form_data)
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
end
