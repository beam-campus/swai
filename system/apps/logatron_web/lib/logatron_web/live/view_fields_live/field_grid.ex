defmodule LogatronWeb.ViewFieldsLive.FieldGrid do
  use LogatronWeb, :live_component

  @moduledoc """
    The live component for the field grid.
  """

  alias Lives.Service, as: Lives

  # def get_lives(mng_farm_id),
  #   do: Lives.get_by_mng_farm_id(mng_farm_id)

  def get_cell_color(coords, lives) do
    "black"
  end

  def get_cell_text(coords, lives) do
    "0"
  end

  def get_cell_state(lives, col, row) do
    "alive"
  end

  ################################### CALLBACKS ###################################
  @impl true
  def update(assigns, socket) do
    # mng_farm_id = assigns.mng_farm_id
    # lives = Lives.get_by_mng_farm_id(mng_farm_id)
    {
      :ok,
      socket
      |> assign(assigns)
      # |> assign(lives: lives)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= for row <- 1..@field.rows do  %>
      <div class="flex">
      <%= for col <- 1..@field.cols do %>
        <.live_component
          module={LogatronWeb.ViewFieldsLive.FieldCell}
          id={@current_user.id <> "field-cell" <> "#{@field.depth}" <> "_col_#{col}" <> "_row_#{row}"}
          row={row}
          col={col}
          field={@field}
          current_user={@current_user}
          mng_farm_id={@mng_farm_id}
          cell_states={@cell_states}
        />
      <% end %>
      </div>
      <% end %>
    </div>
    """
  end
end
