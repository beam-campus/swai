defmodule TrainSwarmProc.Configure.Payload.V1 do
  @moduledoc """
  Cmd module for initializing the swarm training process.
  """
  use Ecto.Schema
  # use Decoratex.Schema

  # alias Edge.Init, as: EdgeInit
  alias TrainSwarmProc.Configure.Payload.V1,
    as: TrainingConfig
    alias MnemonicSlugs

  @all_fields [
    :swarm_size,
    :nbr_of_generations,
    :drone_depth,
    :generation_epoch_in_minutes,
    :select_best_count,
    :cost_in_tokens,
    :edge_id,
    :swarm_name
  ]

  @flat_fields [
    :swarm_size,
    :nbr_of_generations,
    :drone_depth,
    :generation_epoch_in_minutes,
    :select_best_count,
    :cost_in_tokens,
    :edge_id,
    :swarm_name
  ]

  require Logger
  require Jason

  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:swarm_size, :integer, default: 5)
    field(:nbr_of_generations, :integer, default: 5)
    field(:drone_depth, :integer, default: 3)
    field(:generation_epoch_in_minutes, :integer, default: 1)
    field(:select_best_count, :integer, default: 2)
    field(:cost_in_tokens, :integer, default: 0)
    field(:edge_id, :binary_id)
    field(:swarm_name, :string, default: MnemonicSlugs.generate_slug(3))
  end


  def changeset(%TrainingConfig{} = struct, params) do
    changes =
      struct
      |> cast(params, @flat_fields)
      |> validate_number(:swarm_size, greater_than: 4)
      |> validate_number(:nbr_of_generations, greater_than: 4)
      |> validate_number(:drone_depth, greater_than: 2)
      |> validate_number(:generation_epoch_in_minutes, greater_than: 1)
      |> validate_number(:select_best_count, greater_than: 1)
      |> validate_number(:cost_in_tokens, greater_than: -1)
    # Logger.alert("Changeset: #{inspect(changes)}")
    changes
  end

  def from_map(%{} = map) do
    struct = %TrainingConfig{}

    case changeset(struct, map) do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
