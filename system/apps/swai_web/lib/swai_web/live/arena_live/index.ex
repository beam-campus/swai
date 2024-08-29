defmodule SwaiWeb.ArenaLive.Index do
  use SwaiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
    socket
    |> assign(
      scape: Schema.Scape.test_scape()
      )
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="flex justify-center pt-10">
        <.live_component
          id="arena-map"
          module={SwaiWeb.ArenaMap}
          scape={@scape}
        />
      </div>
    """
  end

end
