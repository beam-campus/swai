defmodule Cell.Effect do
  use Ecto.Schema

  @moduledoc """
  Cell.Effect is the struct that identifies the state of a Cell.
  """

  alias Cell.Effect, as: CellEffect
  alias Schema.Id, as: Id

  require Logger

  @id_prefix "effect"

  @all_fields [
    :id,
    :name,
    :description,
    :effect_target,
    :effect_type,
    :effect_value
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:description, :string)
    field(:effect_target, :string)
    field(:effect_type, :string)
    field(:effect_value, :integer)
  end

  def food1(),
    do: %CellEffect{
      id: Id.new(@id_prefix, "food1") |> Id.as_string(),
      name: "food1",
      description: "Food of type 1",
      effect_target: "energy",
      effect_type: "BoT",
      effect_value: :rand.uniform(5)
    }

  def disease1(),
    do: %CellEffect{
      id: Id.new(@id_prefix, "disease1") |> Id.as_string(),
      name: "disease1",
      description: "Disease of type 1",
      effect_target: "health",
      effect_type: "DoT",
      effect_value: -:rand.uniform(1)
    }

  def heal1(),
    do: %CellEffect{
      id: Id.new(@id_prefix, "heal1") |> Id.as_string(),
      name: "heal1",
      description: "Healing of type 1",
      effect_target: "health",
      effect_type: "HoT",
      effect_value: :rand.uniform(2)
    }
end
