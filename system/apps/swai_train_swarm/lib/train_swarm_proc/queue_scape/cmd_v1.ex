
defmodule TrainSwarmProc.QueueScape.CmdV1 do
  @moduledoc """
  Command to start a swarm training.
  """
  use Ecto.Schema

  alias Scape.Init, as: ScapeInit
  alias TrainSwarmProc.QueueScape.CmdV1, as: QueueScape

  import Ecto.Changeset

  require Jason.Encoder

  @all_fields [:agg_id, :payload]



  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema() do
    field(:agg_id, :binary_id)
    embeds_one(:payload, ScapeInit)
  end


  def changeset(%QueueScape{} = seed, %{} = attrs) do
    seed
    |> cast(attrs, @all_fields)
    |> cast_embed(:payload, with: &ScapeInit.changeset/2)
    |> validate_required(@all_fields)
  end

  def from_map(%QueueScape{} = seed, %{} = map) do
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
