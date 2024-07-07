defmodule SwaiWeb.MarketplaceLive.ModelCard do
  use SwaiWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={"section-card " <> active_class(@biotope.is_active?)}>
      <div class="section-card-header">
        <img class="h-24 w-full object-cover opacity-80 rounded radius-5"
        src={"#{@biotope.image_url}"} alt={"#{@biotope.id}"}>
      </div>
      <div class="section-card-body">
        <p class="text-sm font-medium uppercase">
          <%= @biotope.theme %>
        </p>
        <a href="#{Routes.biotope_path(@socket, :show, @biotope)}"
        class="block mt-2 text-xl font-semibold text-lt-section-header">
          <%= @biotope.name %>
        </a>
        <p class="mt-3 text-base text-white">
          <%= @biotope.description %>
        </p>
        <%= if @biotope.is_active? do %>
          <div class="button-row mt-4 flex justify-between">
            <button class="btn-view">View</button>
            <.link patch={~p"/train_swarm/#{@biotope.id}"}>
            Train a Swarm
            </.link>

            <button class="btn-dashboard">Dashboard</button>
          </div>
        <% else %>
          <div class="button-row mt-4 flex justify-between">
            <button class="btn-view">View</button>
            <button class="btn-sponsor">Sponsor this Model</button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp active_class(true), do: "active-biotope"
  defp active_class(false), do: "inactive-biotope"



end
