defmodule LogatronWeb.AnimalLive.Index do
  use LogatronWeb, :live_view

  alias Logatron.Born2Dieds
  alias Logatron.Born2Dieds.Animal

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :born_2_dieds, Born2Dieds.list_born_2_dieds())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Animal")
    |> assign(:animal, Born2Dieds.get_animal!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Animal")
    |> assign(:animal, %Animal{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Born 2 dieds")
    |> assign(:animal, nil)
  end

  @impl true
  def handle_info({Web.AnimalLive.FormComponent, {:saved, animal}}, socket) do
    {:noreply, stream_insert(socket, :born_2_dieds, animal)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    animal = Born2Dieds.get_animal!(id)
    {:ok, _} = Born2Dieds.delete_animal(animal)

    {:noreply, stream_delete(socket, :born_2_dieds, animal)}
  end
end
