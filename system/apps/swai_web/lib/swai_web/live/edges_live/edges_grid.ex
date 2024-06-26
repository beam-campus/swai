defmodule SwaiWeb.EdgesLive.EdgesGrid do
  use SwaiWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-2">
      <div class="flex flex-wrap justify-start gap-2">
        <%= for edge <- @edges do %>
          <div class="flex min-w-0 w-auto">
            <.live_component
              id={edge.id <> "_edge_card_" <> @current_user.id}
              module={SwaiWeb.EdgesLive.EdgeCard}
              edge={edge}
            />
          </div>
        <% end %>
      </div>
    </div>
    """
  end

end
