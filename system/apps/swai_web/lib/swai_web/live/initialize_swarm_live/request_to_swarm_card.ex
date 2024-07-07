defmodule SwaiWeb.InitializeSwarmLive.RequestToSwarmCard do
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
        <p class="card-header-title">
        <span>I, <%= @current_user.email %>
        hereby request a license to evolve
        <input class="input rounded" type="number" id="size" name="size" placeholder="Enter Number of Generations" value={@swarm_specs.generations} required /> generations
        of a swarm of <input class="input rounded" type="number" id="size" name="size" placeholder="Enter Swarm Size" value={@swarm_specs.size} required/> workers
        for the <%= @biotope.name %> ecosystem, during <input class="input rounded" type="number" id="size" name="size" placeholder="Enter the duration" value={@swarm_specs.budget} required/> hours
        starting on <input class="input rounded" type="timestamp" id="start_time" name="start_time" value={@swarm_specs.start_time} required/>
        </span>
        </p>
      </div>
      over
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
