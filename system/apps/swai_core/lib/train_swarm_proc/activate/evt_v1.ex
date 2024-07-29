defmodule TrainSwarmProc.Activate.EvtV1 do
  @moduledoc """
  The schema for the Activated event.
  """

  use Ecto.Schema

  import Ecto.Changeset

  require Logger
  require Jason.Encoder

  alias TrainSwarmProc.Activate.EvtV1, as: Activated


  @all_fields [
    :agg_id,
    :payload
  ]

  @required_fields [
    :agg_id,
    :payload
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:agg_id, :string)
    embeds_one(:payload, TrainSwarmProc.Activate.PayloadV1)
  end
end
