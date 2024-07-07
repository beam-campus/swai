defmodule SwaiWeb.DroneOrderLive.FormComponent do
  use SwaiWeb, :live_component

  alias Swai.Marketplace

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage drone_order records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="drone_order-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:quantity]} type="number" label="Quantity" />
        <.input field={@form[:price_in_cents]} type="number" label="Price in cents" />
        <.input field={@form[:currency]} type="text" label="Currency" />
        <.input field={@form[:status]} type="number" label="Status" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Drone order</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{drone_order: drone_order} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Marketplace.change_drone_order(drone_order))
     end)}
  end

  @impl true
  def handle_event("validate", %{"drone_order" => drone_order_params}, socket) do
    changeset = Marketplace.change_drone_order(socket.assigns.drone_order, drone_order_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"drone_order" => drone_order_params}, socket) do
    save_drone_order(socket, socket.assigns.action, drone_order_params)
  end

  defp save_drone_order(socket, :edit, drone_order_params) do
    case Marketplace.update_drone_order(socket.assigns.drone_order, drone_order_params) do
      {:ok, drone_order} ->
        notify_parent({:saved, drone_order})

        {:noreply,
         socket
         |> put_flash(:info, "Drone order updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_drone_order(socket, :new, drone_order_params) do
    case Marketplace.create_drone_order(drone_order_params) do
      {:ok, drone_order} ->
        notify_parent({:saved, drone_order})

        {:noreply,
         socket
         |> put_flash(:info, "Drone order created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
