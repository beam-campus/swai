defmodule SwaiWeb.SwarmLive.FormComponent do
  use SwaiWeb, :live_component

  alias Swai.Swarms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage swarm records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="swarm-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:user_id]} type="text" label="User" />
        <.input field={@form[:status]} type="number" label="Status" />
        <.input field={@form[:biotope_id]} type="text" label="Biotope" />
        <.input field={@form[:edge_id]} type="text" label="Edge" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Swarm</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{swarm: swarm} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Swarms.change_swarm(swarm))
     end)}
  end

  @impl true
  def handle_event("validate", %{"swarm" => swarm_params}, socket) do
    changeset = Swarms.change_swarm(socket.assigns.swarm, swarm_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"swarm" => swarm_params}, socket) do
    save_swarm(socket, socket.assigns.action, swarm_params)
  end

  defp save_swarm(socket, :edit, swarm_params) do
    case Swarms.update_swarm(socket.assigns.swarm, swarm_params) do
      {:ok, swarm} ->
        notify_parent({:saved, swarm})

        {:noreply,
         socket
         |> put_flash(:info, "Swarm updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_swarm(socket, :new, swarm_params) do
    case Swarms.create_swarm(swarm_params) do
      {:ok, swarm} ->
        notify_parent({:saved, swarm})

        {:noreply,
         socket
         |> put_flash(:info, "Swarm created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
