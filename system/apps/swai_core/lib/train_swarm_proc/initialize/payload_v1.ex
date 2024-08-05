defmodule TrainSwarmProc.Initialize.PayloadV1 do
  @moduledoc """
  Cmd module for initializing the swarm training process.
  """
  use Ecto.Schema

  # alias Edge.Init, as: EdgeInit
  alias TrainSwarmProc.Initialize.PayloadV1, as: Initialization

  @all_fields [
    :license_id,
    :swarm_id,
    :user_id,
    :biotope_id,
    :biotope_name,
    :algorithm_id,
    :algorithm_name,
    :algorithm_acronym,
    :swarm_name,
    :swarm_size,
    :swarm_time_min,
    :cost_in_tokens,
    :available_tokens
  ]

  @flat_fields [
    :license_id,
    :swarm_id,
    :user_id,
    :biotope_id,
    :biotope_name,
    :algorithm_id,
    :algorithm_name,
    :algorithm_acronym,
    :swarm_name,
    :swarm_size,
    :swarm_time_min,
    :cost_in_tokens,
    :available_tokens
  ]

  @required_fields [
    :swarm_id,
    :user_id,
    :biotope_id,
    :biotope_name,
    :algorithm_id,
    :algorithm_name,
    :algorithm_acronym,
    :swarm_name,
    :swarm_size,
    :swarm_time_min,
    :cost_in_tokens,
    :available_tokens
  ]

  require Logger
  require Jason

  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:license_id, :binary_id)
    field(:swarm_id, :binary_id, default: UUID.uuid4())
    field(:user_id, :binary_id)
    field(:biotope_id, :binary_id)
    field(:biotope_name, :string)
    field(:algorithm_id, :binary_id)
    field(:algorithm_name, :string)
    field(:algorithm_acronym, :string)
    field(:swarm_name, :string)
    field(:swarm_size, :integer)
    field(:swarm_time_min, :integer)
    field(:cost_in_tokens, :integer)
    field(:available_tokens, :integer)
  end

  def changeset(%Initialization{} = seed, params) when is_struct(params),
    do: changeset(seed, Map.from_struct(params))
    
  def changeset(%Initialization{} = seed, params) when is_map(params) do
    seed
    |> cast(params, @flat_fields)
    |> validate_required(@required_fields)
  end

  def new(user_id, biotope_id, biotope_name) do
    %Initialization{
      user_id: user_id,
      biotope_id: biotope_id,
      biotope_name: biotope_name
    }
  end

  def from_map(%Initialization{} = seed, map) when is_struct(map),
    do: from_map(seed, Map.from_struct(map))

  def from_map(%Initialization{} = seed, map) when is_map(map) do
    case changeset(seed, map) do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
