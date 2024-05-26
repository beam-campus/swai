defmodule Logatron.MngFarm.State do
  @moduledoc """
  Logatron.MngFarm.State is a GenServer that holds the state of a Farm.
  """
  use Ecto.Schema


  embedded_schema() do
    field(:aggregate_id, :string)
    embeds_one(:farm, Schema.Farm)
  end


end
