defmodule TrainSwarmProc.Activate.PayloadV1 do
  @moduledoc """
  Payload module for activating the swarm training process.
  """
  use Ecto.Schema

  import Ecto.Changeset

  require Logger
  require Jason.Encoder

  alias TrainSwarmProc.Activate.PayloadV1,
    as: ActivatePayload

  @all_fields [
    :training_id,
    :swarm_id,
    :edge_id,
    :scape_id
  ]

  @required_fields [
    :training_id,
    :swarm_id,
    :edge_id,
    :scape_id
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:training_id, :string)
    field(:swarm_id, :string)
    field(:edge_id, :string)
    field(:scape_id, :string)
  end

  @impl true
  def changeset(%ActivatePayload{} = payload, %{} = attrs) do
    payload
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
  end

  def from_map(%TrainSwarmProc.Activate.PayloadV1{} = seed, %{} = map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        changeset
        |> apply_changes()

      changeset ->
        Logger.error("Failed to create ActivatePayload from map: #{inspect(map)}")
        {:error, changeset}
    end
  end
end
