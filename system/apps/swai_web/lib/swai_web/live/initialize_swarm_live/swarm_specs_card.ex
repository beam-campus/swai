defmodule SwaiWeb.InitializeSwarmLive.SwarmSpecsCard do
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
    <div>
    <form class="section-card" phx-submit="save_swarm_specs">
      <div class="card-header">
        <p class="card-header-title">Swarm Specifications</p>
      </div>
      <div class="card-content">
        <div class="field">
          <label class="label" for="name">Name</label>
          <div class="control">
            <input class="input" type="text" id="name" name="name" placeholder="Enter Swarm Name" value={@swarm_specs.name} required>
          </div>
        </div>
        <div class="field">
          <label class="label" for="size">Size</label>
          <div class="control">
            <input class="input" type="number" id="size" name="size" placeholder="Enter Swarm Size" value={@swarm_specs.size} required>
          </div>
        </div>
        <div class="field">
          <label class="label" for="description">Description</label>
          <div class="control">
            <textarea class="textarea" id="description" name="description" placeholder="Describe the Swarm" required>{@swarm_specs.description}</textarea>
          </div>
        </div>
      </div>
      <div class="card-footer">
        <button type="submit" class="button is-primary">Submit</button>
        <button type="button" class="button" phx-click="discard_changes">Discard</button>
      </div>
    </form>
    </div>
    """
  end




end
