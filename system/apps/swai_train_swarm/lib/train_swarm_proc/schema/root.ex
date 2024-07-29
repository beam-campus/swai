defmodule TrainSwarmProc.Schema.Root do
  @moduledoc """
  Documentation for `Root`.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias TrainSwarmProc.Schema.Root,
    as: Root

  alias Schema.SwarmTraining, as: SwarmTraining

  @all_fields [
    :swarm_training
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    embeds_one(:swarm_training, SwarmTraining)
  end
end
