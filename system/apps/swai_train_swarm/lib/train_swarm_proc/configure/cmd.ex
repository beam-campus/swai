defmodule TrainSwarmProc.Configure.Cmd.V1 do
  @moduledoc """
  Cmd module for configuring the swarm training process.
  """
  use Ecto.Schema

  alias TrainSwarmProc.Configure.Cmd.V1, as: Configure
  alias TrainSwarmProc.Configure.Payload.V1, as: Payload

  @all_fields [
    :agg_id,
    :payload
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:agg_id, :binary_id)
    embeds_one(:payload, Payload)
  end
end
