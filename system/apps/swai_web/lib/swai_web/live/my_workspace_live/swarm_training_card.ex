defmodule SwaiWeb.MyWorkspaceLive.SwarmLicenseCard do
  use SwaiWeb, :live_component

  alias Schema.SwarmLicense, as: SwarmLicense
  alias Schema.SwarmLicense.Status, as: Status

  @status_unknown Status.unknown()
  @status_license_initialized Status.license_initialized()
  @status_license_configured Status.license_configured()
  @status_license_paid Status.license_paid()
  @status_license_blocked Status.license_blocked()
  @status_license_active Status.license_active()

  @status_scape_queued Status.scape_queued()
  @status_scape_started Status.scape_started()
  @status_scape_paused Status.scape_paused()
  @status_scape_cancelled Status.scape_cancelled()
  @status_scape_completed Status.scape_completed()

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  attr :swarm_license, SwarmLicense

  defp card_header(assigns) do
    ~H"""
    <div class="section-card-header flex items-center">
      <span class={"border rounded p-1 font-regular text-xs badge #{status_style(@swarm_license.status)}"}>
        <%= Status.to_string(@swarm_license.status) %>
      </span>
      <p class="ml-10 text-xl font-regular text-swBrand-dark"><%= @swarm_license.biotope_name %></p>
      <p class="ml-10 font-regular text-swBrand-light"><%= @swarm_license.swarm_name %></p>
      <.button class="ml-auto  btn-observe ">Observe the Swarm</.button>
    </div>
    """
  end

  attr :swarm_license, SwarmLicense

  defp card_body(assigns) do
    ~H"""
    <div class="section-card-body">
      <div class="section">
        <div class="flex flex-row justify-between">
          <p><strong>Size:</strong> <%= @swarm_license.swarm_size %> particles</p>
          <p>
            <strong>Swarming time:</strong> <%= @swarm_license.generation_epoch_in_minutes %> minutes
          </p>
          <p><strong>Cost:</strong> <%= @swarm_license.cost_in_tokens %> tokens</p>
        </div>
      </div>
    </div>
    """
  end

  attr :swarm_license, SwarmLicense

  defp card_footer(assigns) do
    ~H"""
    <div class="section-card-footer flex flex-row"></div>
    """
  end

  defp card_line(assigns) do
    ~H"""
    <div class="card-line flex items-center">
      <p class={"border rounded p-1 font-regular text-xs badge #{status_style(@swarm_license.status)}"}>
        <%= Status.to_string(@swarm_license.status) %>
      </p>
      <p class="ml-10 font-regular text-swBrand-dark"><%= @swarm_license.biotope_name %></p>
      <p class="ml-10 font-regular text-swBrand-light"><%= @swarm_license.swarm_name %></p>
      <.link class="ml-auto  btn-observe">Observe the Swarm</.link>
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="single-line-card bg-white shadow-md rounded-lg py-4">
      <.card_line swarm_license={@swarm_license} />
    </div>
    """
  end

  defp status_style(status),
    do: Status.style() |> Map.get(status)

  defp active_class(true), do: "active-biotope"
  defp active_class(false), do: "inactive-biotope"
end
