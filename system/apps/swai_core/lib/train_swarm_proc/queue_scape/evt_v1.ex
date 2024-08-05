defmodule TrainSwarmProc.QueueScape.EvtV1 do
  use Ecto.Schema

  import Ecto.Changeset

  require Logger
  require Jason.Encoder

  alias TrainSwarmProc.QueueScape.EvtV1, as: Queued
  alias Scape.Init, as: ScapeInit

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
    embeds_one(:payload, ScapeInit)
  end

  def changeset(%Queued{} = payload, %{} = attrs) when is_struct(attrs),
    do: changeset(payload, Map.from_struct(attrs))

  def changeset(%Queued{} = payload, %{} = attrs) when is_map(attrs) do
    payload
    |> cast(attrs, @flat_fields)
    |> cast_embed(:payload, with: &ScapeInit.changeset/2)
    |> validate_required(@required_fields)
  end

  def from_map(seed, map) when is_struct(map),
    do: from_map(seed, Map.from_struct(map))

  def from_map(%Queued{} = seed, map) when is_map(map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok,  apply_changes(changeset)}

      changeset ->
        Logger.error("Failed to create Queued from map: #{inspect(map)}")
        {:error, changeset}
    end
  end
end
