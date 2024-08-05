defmodule TrainSwarmProc.PayLicense.PayloadV1 do
  @moduledoc """
    This module is responsible for the schema of the payload for the PayLicense
    command. This schema is used to validate the incoming data and to convert
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias TrainSwarmProc.PayLicense.PayloadV1, as: Payment

  require Jason.Encoder

  @all_fields [
    :license_id,
    :swarm_id,
    :swarm_size,
    :swarm_time_min,
    :available_tokens,
    :cost_in_tokens,
    :user_id,
    :biotope_id,
    :swarm_name,
    :algorithm_id,
    :algorithm_acronym
  ]

  @required_fields [
    :license_id,
    :swarm_id,
    :swarm_size,
    :swarm_time_min,
    :available_tokens,
    :cost_in_tokens,
    :user_id,
    :biotope_id,
    :swarm_name,
    :algorithm_id,
    :algorithm_acronym
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:license_id, :binary_id)
    field(:swarm_id, :binary_id)
    field(:swarm_size, :integer)
    field(:swarm_time_min, :integer)
    field(:available_tokens, :integer)
    field(:cost_in_tokens, :integer)
    field(:user_id, :binary_id)
    field(:biotope_id, :binary_id)
    field(:swarm_name, :string)
    field(:algorithm_id, :binary_id)
    field(:algorithm_acronym, :string)

  end

  def changeset(%Payment{} = seed, params) when is_struct(params),
    do: changeset(seed, Map.from_struct(params))

  def changeset(%Payment{} = seed, params \\ %{}) when is_map(params) do
    seed
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  def from_map(%Payment{} = seed, map) when is_struct(map),
    do: from_map(seed, Map.from_struct(map))

  def from_map(%Payment{} = seed, map) when is_map(map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
