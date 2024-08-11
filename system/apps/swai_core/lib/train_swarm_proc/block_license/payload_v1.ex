defmodule TrainSwarmProc.BlockLicense.PayloadV1 do
  @moduledoc """
  This module is responsible for handling the payload of the block license event.
  """
  use Ecto.Schema

  import Ecto.Changeset
  require Logger
  require Jason.Encoder
  alias TrainSwarmProc.BlockLicense.PayloadV1, as: BlockInfo

  @all_fields [
    :reason,
    :additional_info,
    :instructions
  ]

  @flat_fields [
    :reason,
    :additional_info,
    :instructions
  ]

  @required_fields [
    :reason
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:reason, :string)
    field(:additional_info, :string)
    field(:instructions, :string)
  end

  def changeset(%BlockInfo{} = seed, attrs) when is_struct(attrs),
    do: changeset(seed, Map.from_struct(attrs))

  def changeset(%BlockInfo{} = seed, attrs) when is_map(attrs) do
    seed
    |> cast(attrs, @flat_fields)
    |> validate_required(@required_fields)
  end

  def from_map(seed, map) when is_struct(map),
    do: from_map(seed, Map.from_struct(map))

  def from_map(%BlockInfo{} = seed, map) when is_map(map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        Logger.error("Failed to create BlockInfo from map: #{inspect(map)}")
        {:error, changeset}
    end
  end
end
