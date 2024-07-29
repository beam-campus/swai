defmodule SwaiWeb.MarketplaceLive.BiotopeCard do
  use SwaiWeb, :live_component

  alias TrainSwarmProc.Initialize.Payload.V1, as: RequestLicense
  require Logger

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
        <img class="h-24 w-full object-cover opacity-80 rounded radius-10"
        src={"#{@biotope.image_url}"} alt={"#{@biotope.id}"}>
      </div>
      <div class="section-card-body">
        <div>
          <p class="text-xl font-semibold uppercase">
            <%= @biotope.theme %>
          </p>
          <a href="#{Routes.biotope_path(@socket, :show, @biotope)}"
          class="block mt-2 text-xl font-semibold text-lt-section-header">
            <%= @biotope.name %> (<%= @biotope.biotope_type %>)
          </a>
          <p class="mt-3 text-base text-swBrand-light">
            <%= @biotope.description %>
          </p>
          <p class="mt-1 text-base text-swBrand-dark">
            <%= @biotope.objective %>
          </p>
        </div>
        <div class="button-row mt-4 flex justify-between">
        <%= if @biotope.is_active? do %>
          <div>

            <button class="btn-view">View</button>
            <.link patch={~p"/marketplace/start-swarm/#{@biotope.id}"}>
            <.button>Swarm!</.button>
            </.link>
            <button class="btn-dashboard">Dashboard</button>

            </div>


        <% else %>

        <div>


            <.button class="btn-view">View</.button>
            <.button class="btn-sponsor">Sponsor this Model</.button>

        </div>

        <% end %>
        </div>
      </div>

    </div>
    """
  end




  defp active_class(true), do: "active-biotope"
  defp active_class(false), do: "inactive-biotope"



end
