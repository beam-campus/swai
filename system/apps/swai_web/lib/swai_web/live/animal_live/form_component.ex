defmodule SwaiWeb.AnimalLive.FormComponent do
  use SwaiWeb, :live_component

  alias Swai.Born2Dieds

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage animal records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="animal-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:id]} type="text" label="Id" />
        <.input field={@form[:edge_id]} type="text" label="Edge" />
        <.input field={@form[:scape_id]} type="text" label="Scape" />
        <.input field={@form[:region_id]} type="text" label="Region" />
        <.input field={@form[:farm_id]} type="text" label="Farm" />
        <.input field={@form[:field_id]} type="text" label="Field" />
        <.input field={@form[:status]} type="text" label="Status" />
        <.input field={@form[:life_id]} type="text" label="Life" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:gender]} type="text" label="Gender" />
        <.input field={@form[:father_id]} type="text" label="Father" />
        <.input field={@form[:mother_id]} type="text" label="Mother" />
        <.input field={@form[:birth_date]} type="date" label="Birth date" />
        <.input field={@form[:age]} type="number" label="Age" />
        <.input field={@form[:weight]} type="number" label="Weight" />
        <.input field={@form[:energy]} type="number" label="Energy" />
        <.input field={@form[:is_pregnant]} type="checkbox" label="Is pregnant" />
        <.input field={@form[:heath]} type="number" label="Heath" />
        <.input field={@form[:health]} type="number" label="Health" />
        <.input field={@form[:x]} type="number" label="X" />
        <.input field={@form[:y]} type="number" label="Y" />
        <.input field={@form[:z]} type="number" label="Z" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Animal</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{animal: animal} = assigns, socket) do
    changeset = Born2Dieds.change_animal(animal)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"animal" => animal_params}, socket) do
    changeset =
      socket.assigns.animal
      |> Born2Dieds.change_animal(animal_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"animal" => animal_params}, socket) do
    save_animal(socket, socket.assigns.action, animal_params)
  end

  defp save_animal(socket, :edit, animal_params) do
    case Born2Dieds.update_animal(socket.assigns.animal, animal_params) do
      {:ok, animal} ->
        notify_parent({:saved, animal})

        {:noreply,
         socket
         |> put_flash(:info, "Animal updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_animal(socket, :new, animal_params) do
    case Born2Dieds.create_animal(animal_params) do
      {:ok, animal} ->
        notify_parent({:saved, animal})

        {:noreply,
         socket
         |> put_flash(:info, "Animal created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
