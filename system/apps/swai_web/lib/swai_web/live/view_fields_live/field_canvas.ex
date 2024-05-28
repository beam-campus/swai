## Reference https://www.petecorey.com/blog/2019/09/02/animating-a-canvas-with-phoenix-liveview/
defmodule SwaiWeb.ViewFieldsLive.FieldCanvas do
  use SwaiWeb, :live_component

  @moduledoc """
  The live component for the field canvas.
  """



  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end


  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col px-4 py-3 font-mono text-sm">
    <div class="py-0">
    <div class="flex flex-row items-center justify-between">
    <canvas
    id={"#{@current_user.id}" <> "field-canvas" <> "#{@field.depth}"}
    phx-hook="canvas"
    phx-states="{@cell_states}">
    </canvas>
    </div>
    </div>
    </div>
    """
  end



end
