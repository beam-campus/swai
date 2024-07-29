defmodule TrainSwarmProc.Initialize.Cmd.V1 do
  @moduledoc """
  Command module for initializing the swarm training process.
  """
  use Ecto.Schema

  alias TrainSwarmProc.Initialize.Cmd.V1,
    as: Initialize

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
    embeds_one(:payload, SwarmTraining)
  end
end
