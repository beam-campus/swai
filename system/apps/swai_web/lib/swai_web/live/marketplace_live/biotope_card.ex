defmodule SwaiWeb.MarketplaceLive.BiotopeCard do
  use SwaiWeb, :live_component

  alias TrainSwarmProc.Initialize.PayloadV1, as: RequestLicense
  alias Schema.Biotope, as: Biotope

  require Logger

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
    }
  end

  attr :biotope, Biotope
  defp card_header(assigns) do
    ~H"""
    <div class="section-card-header">
      <img class="h-24 w-full object-cover opacity-80 rounded radius-10"
      src={"#{@biotope.image_url}"} alt={"#{@biotope.id}"}>
      <div class="flex flex-row text-swBrand-dark pt-2 font-regular">
        <p><%= @biotope.name %> [<%= @biotope.algorithm_name %>] </p>
        <p class="font-regular uppercase text-swBrand-light ml-auto" id="biotope_theme">
          <%= @biotope.theme %>
        </p>
      </div>
    </div>
    """
  end


  attr :biotope, Biotope
  defp card_body(assigns) do
    ~H"""
    <div class="section-card-body">
        <p class="font-xs text-base">
          <%= @biotope.description %>
        </p>
        <p class="mt-1 text-base">
          <%= @biotope.objectives %>
        </p>
    </div>
    """
  end

  attr :biotope, Biotope
  defp card_footer(assigns) do
    ~H"""
    <div class="button-row mt-1 flex justify-between">
        <%= if @biotope.is_active? do %>
            <%!-- <button class="btn-view">View</button> --%>
            <.link patch={~p"/marketplace/start-swarm/#{@biotope.id}"}>
            <.button>Launch this Swarm!</.button>
            </.link>
            <%!-- <button class="btn-dashboard">Dashboard</button> --%>
        <% else %>
          <.button class="btn-sponsor">Sponsor this Model</.button>
        <% end %>
     </div>
     """
  end



  @impl true
  def render(assigns) do
    ~H"""
    <div class={"section-card " <> active_class(@biotope.is_active?)}>
      <.card_header biotope={@biotope} />
      <.card_body biotope={@biotope} />
      <.card_footer biotope={@biotope} />
    </div>
    """
  end




  defp active_class(true), do: "active-biotope"
  defp active_class(false), do: "inactive-biotope"



end
