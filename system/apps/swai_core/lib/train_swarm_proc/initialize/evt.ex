defmodule TrainSwarmProc.Initialize.Evt.V1 do
  @moduledoc """
  Event module for TrainSwarmProc.Initialize
  """
  use Ecto.Schema

  alias TrainSwarmProc.Initialize.Payload.V1,
    as: Payload

  require Jason.Encoder

  @all_fields [
    :agg_id,
    :version,
    :payload
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:agg_id, :binary_id)
    field(:version, :integer, default: 1)
    embeds_one(:payload, Payload)
  end
end
