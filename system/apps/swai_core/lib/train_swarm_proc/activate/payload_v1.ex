defmodule TrainSwarmProc.Activate.PayloadV1 do
  @moduledoc """
  Payload module for activating the swarm training process.
  """
  use Ecto.Schema

  import Ecto.Changeset

  require Logger
  require Jason.Encoder

  alias TrainSwarmProc.Activate.PayloadV1, as: Activation
  alias Schema.Vector, as: Vector

  @all_fields [
    :license_id,
    :user_id,
    :swarm_id,
    :biotope_id,
    :swarm_size,
    :swarm_time_min,
    :swarm_name,
    :algorithm_id,
    :algorithm_acronym,
  ]

  @required_fields [
    :license_id,
    :user_id,
    :swarm_id,
    :biotope_id,
    :swarm_size,
    :swarm_time_min,
    :swarm_name,
    :algorithm_id,
    :algorithm_acronym,
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:license_id, :binary_id)
    field(:user_id, :binary_id)
    field(:swarm_id, :binary_id)
    field(:biotope_id, :binary_id)
    field(:swarm_size, :integer)
    field(:swarm_time_min, :integer)
    field(:swarm_name, :string)
    field(:algorithm_id, :binary_id)
    field(:algorithm_acronym, :string)
  end

  def changeset(%Activation{} = seed, params) when is_struct(params),
    do: changeset(seed, Map.from_struct(params))

  def changeset(%Activation{} = seed, attrs) when is_map(attrs) do
    seed
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
  end

  def from_map(%Activation{} = seed, map) when is_struct(map),
    do: from_map(seed, Map.from_struct(map))

  def from_map(%Activation{} = seed, map) when is_map(map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        Logger.error("Failed to create Activation from map: #{inspect(map)}")
        {:error, changeset}
    end
  end
end
