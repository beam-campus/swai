defmodule SwaiWeb.MngStationsLive.MngDeviceComponent do
  use SwaiWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div class="flex flex-col">
      <h1>Device</h1>
      <div class="swai-device"">
        <div class="flex flex-col">
          <div class="flex flex-row">
            <div class="flex flex-col">
              <label class="text-sm font-semibold">Name</label>
              <input class="input" value="<%= @device.name %>" />
            </div>
            <div class="flex flex-col">
              <label class="text-sm font-semibold">Type</label>
              <input class="input" value="<%= @device.type %>" />
            </div>
          </div>
          <div class="flex flex-row">
            <div class="flex flex-col">
              <label class="text-sm font-semibold">IP</label>
              <input class="input" value="<%= @device.ip %>" />
            </div>
            <div class="flex flex-col">
              <label class="text-sm font-semibold">Port</label>
              <input class="input" value="<%= @device.port %>" />
            </div>
          </div>
          <div class="flex flex-row">
            <div class="flex flex-col">
              <label class="text-sm font-semibold">Username</label>
              <input class="input" value="<%= @device.username %>" />
            </div>
            <div class="flex flex-col">
              <label class="text-sm font-semibold">Password</label>
              <input class="input" value="<%= @device.password %>" />
            </div>
          </div>
          <div class="flex flex-row">
            <div class="flex flex-col">
              <label class="text-sm font-semibold">Station</label>
              <input class="input" value="<%= @device.station_id %>" />
            </div>
            <div class="flex flex-col">
              <label class="text-sm font-semibold">Status</label>
              <input class="input" value="<%= @device.status %>" />
            </div>
          </div>
        </div>

    </div>
    """
  end


end
