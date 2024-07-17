defmodule TrainSwarmProc.Configure.Evt do
  use Ecto.Schema
  require Jason.Encoder

  @all_fields [
    :agg_id,
    :payload
  ]



  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:agg_id, :binary_id)
    embeds_one(:payload, TrainSwarmProc.Initialize.Payload)
  end

end
