defmodule TrainSwarmProc.Initialize.Payload do
  @moduledoc """
  Cmd module for initializing the swarm training process.
  """
  use Ecto.Schema
  # use Decoratex.Schema

  # alias Edge.Init, as: EdgeInit
  alias Schema.Biotope, as: Biotope
  alias Schema.User, as: User
  alias TrainSwarmProc.Initialize.Payload, as: RequestLicense

  @all_fields [
    :id,
    :swarm_size,
    :nbr_of_generations,
    :drone_depth,
    :generation_epoch_in_minutes,
    :select_best_count,
    :user_id,
    :biotope_id,
    :cost_in_tokens
  ]

  @flat_fields [
    :swarm_size,
    :nbr_of_generations,
    :drone_depth,
    :generation_epoch_in_minutes,
    :select_best_count,
    :user_id,
    :biotope_id
  ]

  @required_fields [
    :id,
    :swarm_size,
    :nbr_of_generations,
    :drone_depth,
    :generation_epoch_in_minutes,
    :select_best_count,
    :user_id,
    :biotope_id,
    :cost_in_tokens
  ]

  require Logger
  require Jason

  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:id, :binary_id, default: UUID.uuid4())
    field(:swarm_size, :integer, default: 5)
    field(:nbr_of_generations, :integer, default: 5)
    field(:drone_depth, :integer, default: 3)
    field(:generation_epoch_in_minutes, :integer, default: 1)
    field(:select_best_count, :integer, default: 2)
    field(:user_id, :binary_id)
    field(:biotope_id, :binary_id)
    field(:cost_in_tokens, :integer, default: 0)
  end

  defp calculate_cost_in_tokens(%Ecto.Changeset{} = changeset) do
    new_license =
      changeset
      |> apply_changes()

    new_cost =
      new_license.swarm_size *
        new_license.nbr_of_generations *
        new_license.drone_depth *
        new_license.generation_epoch_in_minutes

    Logger.alert("Calculated cost: #{new_cost}")

    new_changeset =
      changeset
      |> put_change(:cost_in_tokens, new_cost)

    Logger.alert("Changeset with Calculated cost: #{inspect(new_changeset)}")
    new_changeset
  end

  def changeset(%RequestLicense{} = struct, params) do
    changes =
      struct
      |> cast(params, @flat_fields)
      |> validate_required(@required_fields)
      |> validate_number(:swarm_size, greater_than: 4)
      |> validate_number(:nbr_of_generations, greater_than: 4)
      |> validate_number(:drone_depth, greater_than: 2)
      |> validate_number(:generation_epoch_in_minutes, greater_than: 1)
      |> validate_number(:select_best_count, greater_than: 1)
      |> calculate_cost_in_tokens()
      |> validate_number(:cost_in_tokens, greater_than: -1)

    Logger.alert("Changeset: #{inspect(changes)}")
    changes
  end

  def new(user_id, biotope_id) do
    %RequestLicense{
      user_id: user_id,
      biotope_id: biotope_id
    }
  end

  def from_map(%{} = map) do
    struct = %RequestLicense{}

    case changeset(struct, map) do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
