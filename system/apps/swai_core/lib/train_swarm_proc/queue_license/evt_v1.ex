defmodule TrainSwarmProc.QueueLicense.EvtV1 do
  @moduledoc """
  Event for a swarm training.
  """
  use Ecto.Schema

  import Ecto.Changeset

  require Jason.Encoder

  alias TrainSwarmProc.QueueLicense.EvtV1, as: Queued
  alias Schema.SwarmLicense, as: License

  @all_fields [
    :agg_id,
    :version,
    :payload
  ]

  @flat_fields [
    :agg_id,
    :version
  ]

  @required_fields [
    :agg_id,
    :version,
    :payload
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:agg_id, :binary_id)
    field(:version, :integer, default: 1)
    embeds_one(:payload, License)
  end

  def changeset(%Queued{} = evt, %{} = attrs) when is_struct(attrs),
    do: changeset(evt, Map.from_struct(attrs))

  def changeset(%Queued{} = evt, %{} = attrs) when is_map(attrs) do
    evt
    |> cast(attrs, @flat_fields)
    |> cast_embed(:payload, with: &License.changeset/2)
    |> validate_required(@required_fields)
  end

  def from_map(seed, map) when is_struct(map),
    do: from_map(seed, Map.from_struct(map))

  def from_map(%Queued{} = seed, map) when is_map(map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
