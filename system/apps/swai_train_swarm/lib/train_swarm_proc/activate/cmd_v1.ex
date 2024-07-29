defmodule TrainSwarmProc.Activate.CmdV1 do
  @moduledoc """
  Command module for activating the swarm training process.
  """
  use Ecto.Schema

  alias TrainSwarmProc.Activate.CmdV1,
    as: Activate

    alias TrainSwarmProc.Activate.PayloadV1,
    as: ActivatePayload

  alias Schema.SwarmTraining,
    as: SwarmTraining

  @all_fields [
    :agg_id,
    :payload
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:agg_id, :binary_id)
    embeds_one(:payload, ActivatePayload)
  end
end
