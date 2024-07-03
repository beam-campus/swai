defmodule TradeWars.Schema.Fenotype do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  embedded_schema do
    field :recklessness, :integer
    field :aggressiveness, :integer
    field :defensiveness, :integer
    field :co_op_index, :integer
    timestamps()
  end

  


end
