defmodule SwaiWeb.ViewScapesLive.ScapeCard do
  use SwaiWeb, :live_component

  @moduledoc """
  The live component for the scape card.
  """

  @impl true
  def update(assigns, socket) do
    {
      :ok,
     socket
     |> assign(assigns)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="rounded overflow-hidden shadow-lg m-4 bg-cover bg-center" style={"background-image: url(" <> @scape.image_url <> ");"}>
      <div class="px-6 py-4 bg-white bg-opacity-50">
        <div class="font-bold text-xl text-red-800 mb-2"><%= @scape.name %></div>
        <p class="text-gray-700 text-base">
          <%= @scape.description %>
        </p>
      </div>
      <div class="px-6 pt-4 pb-2 bg-white bg-opacity-50 text-gray-800">
        <p><strong>Theme:</strong> <%= @scape.theme %></p>
        <p><strong>Number of Countries:</strong> <%= @scape.nbr_of_countries %></p>
        <p><strong>Minimum Area: </strong><%= @scape.min_area %> km</p>
        <p><strong>Minimum People: </strong> <%= @scape.min_people %></p>
      </div>
      <div class="px-6 pt-4 pb-2 bg-white bg-opacity-50">
        <button class="bg-gray-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
          Learn More
        </button>
        <button class="bg-gray-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
          Contribute
        </button>
        <button class="bg-gray-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
          View Hives
        </button>

      </div>
    </div>
    """
  end
end
