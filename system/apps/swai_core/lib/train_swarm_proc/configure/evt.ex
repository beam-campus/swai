defmodule TrainSwarmProc.Configure.Evt.V1 do
  use Ecto.Schema
  require Jason.Encoder

  alias TrainSwarmProc.Configure.Payload.V1, as: Payload

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
