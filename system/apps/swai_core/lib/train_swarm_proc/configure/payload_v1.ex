defmodule TrainSwarmProc.Configure.PayloadV1 do
  @moduledoc """
  Cmd module for initializing the swarm training process.
  """
  use Ecto.Schema
  # use Decoratex.Schema

  # alias Edge.Init, as: EdgeInit
  alias TrainSwarmProc.Configure.PayloadV1, as: Configuration

  alias MnemonicSlugs

  @all_fields [
    :license_id,
    :user_id,
    :biotope_id,
    :swarm_id,
    :swarm_name,
    :swarm_size,
    :swarm_time_min,
    :cost_in_tokens,
    :available_tokens,
    :algorithm_id,
    :algorithm_acronym,
  ]

  require Logger
  require Jason

  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:license_id, :binary_id)
    field(:user_id, :binary_id)
    field(:biotope_id, :binary_id)
    field(:swarm_id, :binary_id)
    field(:swarm_name, :string)
    field(:swarm_size, :integer)
    field(:swarm_time_min, :integer)
    field(:cost_in_tokens, :integer)
    field(:available_tokens, :integer)
    field(:algorithm_id, :binary_id)
    field(:algorithm_acronym, :string)
  end

  def changeset(%Configuration{} = seed, params) when is_struct(params),
    do: changeset(seed, Map.from_struct(params))

  def changeset(%Configuration{} = seed, params) when is_map(params) do
    seed
    |> cast(params, @all_fields)
    |> validate_required(@all_fields)
    |> validate_number(:swarm_size, greater_than: 49)
    |> validate_number(:swarm_time_min, greater_than: 14)
    |> validate_number(:cost_in_tokens, greater_than: -1)
    |> validate_number(:available_tokens, greater_than: -1)
  end

  def from_map(%Configuration{} = seed, map) when is_struct(map),
    do: from_map(seed, Map.from_struct(map))

  def from_map(%Configuration{} = seed, map) when is_map(map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
