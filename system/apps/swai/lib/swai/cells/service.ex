defmodule Cells.Service do

  @moduledoc """
  The service for the Cells subsystem.
  """

  alias Lives.Service, as: Lives
  alias Cell.State, as: CellState

  def get_cell_states(nil), do: []

  def get_cell_states(mng_farm_id) do
    Lives.get_by_mng_farm_id(mng_farm_id)
    |> Enum.map(& CellState.from_life/1)
  end



end
