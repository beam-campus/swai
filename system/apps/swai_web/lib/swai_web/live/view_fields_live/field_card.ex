defmodule SwaiWeb.ViewFieldsLive.FieldCard do
  use SwaiWeb, :live_component

  @moduledoc """
  The live component for the field card.
  """

  alias Lives.Service, as: Lives


  def get_lives(mng_farm_id),
    do: Lives.get_by_mng_farm_id(mng_farm_id)

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  # @impl true
  # def render(assigns) do
  #   ~H"""
  #   <div
  #     class="flex flex-col px-4 py-3 font-mono text-sm bg-cover bg-center bg-no-repeat"
  #     style="background-image: url('images/bg-meadow.svg'); background-color: rgba(0, 128, 0, 0.5);">
  #     <div class="py-0">
  #       <div class="flex flex-row items-center justify-between">
  #         <.live_component
  #           module={SwaiWeb.ViewFieldsLive.FieldGrid}
  #           current_user={@current_user}
  #           id={@current_user.id <> "field-grid" <> "#{@field.depth}"}
  #           field={@field}
  #           mng_farm_id={@mng_farm_id}
  #           cell_states={@cell_states}
  #         />
  #       </div>
  #     </div>
  #   </div>
  #   """
  # end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div
        phx-hook="canvas"
        data-cell_states={Jason.encode!(@cell_states)}
        id="canvas-div"
      >
        <canvas
          phx-update="ignore"
          id="canvas">
          Canvas is not supported!
        </canvas>
      </div>
    </div>
    """
  end



end
