defmodule TrainSwarmProc.Initialize.CmdV1 do
  @moduledoc """
  Command module for initializing the swarm training process.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias TrainSwarmProc.Initialize.CmdV1, as: Initialize
  alias Schema.SwarmLicense, as: SwarmLicense

  require Logger

  @all_fields [
    :agg_id,
    :version,
    :payload
  ]

  @flat_fields [
    :agg_id,
    :version
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:agg_id, :binary_id)
    field(:version, :integer, default: 1)
    embeds_one(:payload, SwarmLicense)
  end

  def changeset(%Initialize{} = cmd, attrs) do
    cmd
    |> cast(attrs, @flat_fields)
    |> cast_embed(:payload, with: &SwarmLicense.changeset/2)
    |> validate_required(@all_fields)
  end

  def from_map(%Initialize{} = seed, map) when is_struct(map),
    do: from_map(seed, Map.from_struct(map))

  def from_map(%Initialize{} = seed, map) when is_map(map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        Logger.error("Failed to create Initialize from map: #{inspect(map)}")
        {:error, changeset}
    end
  end
end
