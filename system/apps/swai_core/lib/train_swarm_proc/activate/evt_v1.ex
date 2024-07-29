defmodule TrainSwarmProc.Activate.EvtV1 do
  use Ecto.Schema

  import Ecto.Changeset

  require Logger

  alias TrainSwarmProc.Activate.EvtV1,
    as: Activated

  embedded_schema do
    field(:agg_id, :string)
    embeds_one(:payload, TrainSwarmProc.Activate.PayloadV1)
  end
end
