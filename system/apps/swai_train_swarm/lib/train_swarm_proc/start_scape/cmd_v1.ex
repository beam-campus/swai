defmodule TrainSwarmProc.StartScape.CmdV1 do
  @moduledoc """
  Command to start a swarm training.
  """
  use Ecto.Schema

  alias Scape.Init, as: ScapeInit
  alias TrainSwarmProc.StartScape.CmdV1, as: StartScape

  import Ecto.Changeset

  require Jason.Encoder
  require Logger

  @all_fields [
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

  def changeset(%StartScape{} = seed, %{} = attrs)
      when is_struct(attrs) do
    changeset(seed, Map.from_struct(attrs))
  end


  def changeset(%StartScape{} = seed, %{} = attrs)
      when is_map(attrs) do
    seed
    |> cast(attrs, @all_fields)
    |> cast_embed(:payload, with: &ScapeInit.changeset/2)
    |> validate_required(@all_fields)
  end

  def from_map(seed, map) when is_struct(map) do
    from_map(seed, Map.from_struct(map))
  end

  def from_map(%StartScape{} = seed, %{} = map)
      when is_map(map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        changeset
        |> apply_changes()

      changeset ->
        Logger.error("Failed to create Start from map: #{inspect(map)}")
        {:error, changeset}
    end
  end
end
