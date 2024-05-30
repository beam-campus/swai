defmodule SwaiWeb.ViewFieldsLive.FieldCell do
  use SwaiWeb, :live_component

  @moduledoc """
    The FieldCell is used to render a single cell in the FieldGrid
  """

  alias Cell.State, as: CellState

  require Logger

  # The functional component that renders the cell

  def get_cell_state(cell_states, col, row) do
    cell_state =
      cell_states
      |> Enum.find(&(&1.col == col and &1.row == row))

    case cell_state do
      nil ->
        %CellState{
          col: col,
          row: row,
          content: " ",
          class: "w-5 h-5"
        }

      _ ->
        cell_state
    end
  end

  @impl true
  def update(assigns, socket) do
    cell_state =
      assigns.cell_states
      |> get_cell_state(assigns.col, assigns.row)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:cell_state, cell_state)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={@cell_state.class}>
      <%= @cell_state.content %>
    </div>
    """
  end
  

end
