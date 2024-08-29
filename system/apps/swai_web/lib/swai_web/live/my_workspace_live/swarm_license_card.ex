defmodule SwaiWeb.MyWorkspaceLive.SwarmLicenseCard do
  use SwaiWeb, :live_component

  alias Schema.SwarmLicense, as: License
  alias Schema.SwarmLicense.Status, as: Status
  alias Edge.Init, as: EdgeInit

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  attr(:swarm_license, License)

  defp biotope_box(assigns) do
    ~H"""
      <div class="flex flex-row text-swBrand-dark font-regular mb-2">
        <p><%= @swarm_license.biotope_name %> [<%= @swarm_license.algorithm_name %>] </p>
        <p class="font-regular uppercase text-swBrand-light ml-auto" id="license_theme">
          <%= @swarm_license.theme %>
        </p>
      </div>
    """
  end

  defp get_edge(%{edge: nil}), do: EdgeInit.default()
  defp get_edge(%{edge: edge}), do: edge

  attr(:swarm_license, License)
  attr(:edge, Edge)

  defp status_box(assigns) do
    ~H"""
      <div class="flex flex-row">
        <div class="font-Brand font-regular text-white-600 text-xs">
          <p>License: <%= @swarm_license.license_id %></p>
          <p>Swarm: <%= @swarm_license.swarm_name %></p>
        </div>
        <div class="ml-auto flex flex-col">
          <div class="flex flex-row text-white font-regular text-xs gap-1 mb-auto ml-auto">
            <%= for status <- Status.to_list(@swarm_license.status) do  %>
              <div class={"badge rounded border m-1 p-1 #{status}-status"}><%= status %></div>
            <% end %>
          </div>
        </div>
      </div>
    """
  end

  attr(:swarm_license, License)

  def scape_minimap(assigns) do
    ~H"""
      <div id={"scape-thumbnail-#{@swarm_license.license_id}"} class="scape-minimap">
        <p class="text-center text-white">Scape Minimap</p>
      </div>
    """
  end

  attr(:edge, Edge)

  defp edge_box(assigns) do
    ~H"""
      <div class="flex flex-row text-white font-mono font-regular text-sm mb-2">
        <fieldset class="border p-2 rounded radius-20 w-full">
          <legend class="font-regular ml-2">Swarming on Macula Node </legend>
          <.edge_card node={@edge} />
        </fieldset>
      </div>
    """
  end

  attr :node,  EdgeInit
  defp edge_images(assigns) do
    ~H"""
      <div class="edge-images  flex flex-col">
        <img src={"#{@node.flag_svg}"} alt="Node Image" class="edge-image" />
        <%= if @node.is_container do %>
        <img src={~p"/images/docker-mark.svg"} alt="Node Image" class="edge-image" />
        <% else %>
        <img src={~p"/images/docker-mark.svg"} alt="Node Image" class="edge-image" />
        <% end %>
      </div>
    """
  end

  defp edge_card(assigns) do
    ~H"""
    <div class="edge-card">
      <.edge_images node={@node}/>
      <div class="edge-details">
        <h2 class="font-swBrand text-swBrand-light">
          <%= @node.city %>, <%= @node.country %>
        </h2>
        <p><strong>IP Address:</strong> <%= @node.ip_address %></p>
        <p><strong>ISP:</strong> <%= @node.isp %></p>
        <p><strong>Organization:</strong> <%= @node.org %></p>
        <p><strong>Continent:</strong> <%= @node.continent %></p>
        <p><strong>Timezone:</strong> <%= @node.timezone %> (UTC <%= @node.offset %>)</p>
        <p><strong>Online Since:</strong> <%= @node.online_since %></p>
        <p><strong>Connected Since:</strong> <%= @node.connected_since %></p>
        <div class="edge-status ml-auto">
          <span class={if @node.mobile, do: "status-indicator mobile", else: "status-indicator"}>
            Mobile
          </span>
          <span class={if @node.proxy, do: "status-indicator proxy", else: "status-indicator"}>
            Proxy
          </span>
          <span class={if @node.hosting, do: "status-indicator hosting", else: "status-indicator"}>
            Hosting
          </span>
        </div>
      </div>
    </div>
    """
  end


  attr(:swarm_license, License)

  defp card_header(assigns) do
    ~H"""
    <div class="section-card-header">
        <.biotope_box swarm_license={@swarm_license} />
        <img class="h-24 w-full object-cover opacity-80 rounded radius-10"
        src={"#{@swarm_license.image_url}"} alt={"#{@swarm_license.biotope_id}"}/>
    </div>
    """
  end


  attr :scape,  License
  defp scape_card(assigns) do
    ~H"""
      <div class="section-card-body">
        <.scape_minimap swarm_license={@scape} />
      </div>
    """
  end


  attr :edge,  EdgeInit
  attr :swarm_license,  License
  defp scape_box(assigns) do
    ~H"""
       <div class="flex flex-row text-white font-mono font-regular text-sm mb-2">
        <fieldset class="border p-2 rounded radius-20 w-full">
          <legend class="font-regular ml-2">Scape</legend>
          <.scape_card scape={@swarm_license} />
        </fieldset>
      </div>
    """
  end

  attr(:swarm_license, License)

  defp card_body(assigns) do
    ~H"""
    <div class="section-card-body">
        <.status_box swarm_license={@swarm_license} />
        <.scape_box swarm_license={@swarm_license} />
        <.edge_box edge={get_edge(@swarm_license)} />
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="section-card">
        <.card_header swarm_license={@swarm_license} />
        <.card_body swarm_license={@swarm_license} />
      </div>
    """
  end
end
