defmodule TrainSwarmProc.Schema.Root do
  @moduledoc """
  Documentation for `Root`.
  """
  use Ecto.Schema

  alias Schema.SwarmLicense, as: SwarmLicense

  @all_fields [
    :swarm_license
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    embeds_one(:swarm_license, SwarmLicense)
  end
end
