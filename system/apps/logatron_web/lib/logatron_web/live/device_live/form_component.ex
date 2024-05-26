defmodule LogatronWeb.DeviceLive.FormComponent do
  use LogatronWeb, :live_component

  alias Logatron.Devices

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage device records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="device-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:add]} type="text" label="Add" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:user_id]} type="text" label="User" />
        <.input field={@form[:brand]} type="text" label="Brand" />
        <.input field={@form[:model]} type="text" label="Model" />
        <.input field={@form[:arcitecture]} type="text" label="Arcitecture" />
        <.input field={@form[:cpu]} type="text" label="Cpu" />
        <.input field={@form[:clock_mhz]} type="text" label="Clock mhz" />
        <.input field={@form[:cores]} type="number" label="Cores" />
        <.input field={@form[:ram_gb]} type="number" label="Ram gb" />
        <.input field={@form[:storage_gb]} type="number" label="Storage gb" />
        <.input field={@form[:network]} type="text" label="Network" />
        <.input field={@form[:mac_address]} type="text" label="Mac address" />
        <.input field={@form[:root_os]} type="text" label="Root os" />
        <.input field={@form[:os_version]} type="text" label="Os version" />
        <.input field={@form[:runtime]} type="text" label="Runtime" />
        <.input field={@form[:runtime_version]} type="text" label="Runtime version" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Device</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{device: device} = assigns, socket) do
    changeset = Devices.change_device(device)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"device" => device_params}, socket) do
    changeset =
      socket.assigns.device
      |> Devices.change_device(device_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"device" => device_params}, socket) do
    save_device(socket, socket.assigns.action, device_params)
  end

  defp save_device(socket, :edit, device_params) do
    case Devices.update_device(socket.assigns.device, device_params) do
      {:ok, device} ->
        notify_parent({:saved, device})

        {:noreply,
         socket
         |> put_flash(:info, "Device updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_device(socket, :new, device_params) do
    case Devices.create_device(device_params) do
      {:ok, device} ->
        notify_parent({:saved, device})

        {:noreply,
         socket
         |> put_flash(:info, "Device created successfully")
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
