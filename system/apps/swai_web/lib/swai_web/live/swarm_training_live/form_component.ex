defmodule SwaiWeb.SwarmTrainingLive.FormComponent do
  use SwaiWeb, :live_component

  alias Swai.Workspace

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage swarm_training records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="swarm_training-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:swarm_size]} type="number" label="Swarm size" />
        <.input field={@form[:nbr_of_generations]} type="number" label="Nbr of generations" />
        <.input field={@form[:drone_depth]} type="number" label="Drone depth" />
        <.input field={@form[:generation_epoch_in_minutes]} type="number" label="Generation epoch in minutes" />
        <.input field={@form[:select_best_count]} type="number" label="Select best count" />
        <.input field={@form[:cost_in_tokens]} type="number" label="Cost in tokens" />
        <.input field={@form[:tokens_used]} type="number" label="Tokens used" />
        <.input field={@form[:status]} type="number" label="Status" />
        <.input field={@form[:total_run_time_in_seconds]} type="number" label="Total run time in seconds" />
        <.input field={@form[:budget_in_tokens]} type="number" label="Budget in tokens" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Swarm training</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{swarm_training: swarm_training} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Workspace.change_swarm_training(swarm_training))
     end)}
  end

  @impl true
  def handle_event("validate", %{"swarm_training" => swarm_training_params}, socket) do
    changeset = Workspace.change_swarm_training(socket.assigns.swarm_training, swarm_training_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"swarm_training" => swarm_training_params}, socket) do
    save_swarm_training(socket, socket.assigns.action, swarm_training_params)
  end

  defp save_swarm_training(socket, :edit, swarm_training_params) do
    case Workspace.update_swarm_training(socket.assigns.swarm_training, swarm_training_params) do
      {:ok, swarm_training} ->
        notify_parent({:saved, swarm_training})

        {:noreply,
         socket
         |> put_flash(:info, "Swarm training updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_swarm_training(socket, :new, swarm_training_params) do
    case Workspace.create_swarm_training(swarm_training_params) do
      {:ok, swarm_training} ->
        notify_parent({:saved, swarm_training})

        {:noreply,
         socket
         |> put_flash(:info, "Swarm training created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
