defmodule Logatron.Schema.Stable do
  use Ecto.Schema

  schema "stables" do
    belongs_to :farm, Schema.Farm
    has_many :robots, Schema.Robot
  end
end
