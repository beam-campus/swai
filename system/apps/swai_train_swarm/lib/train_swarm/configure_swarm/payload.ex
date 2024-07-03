defmodule TrainSwarm.ConfigureSwarm.Payload do
  use Ecto.Schema

  alias TrainSwarm.ConfigureSwarm.Payload, as: Payload
  alias Schema.Biotope, as: Biotope
  alias Schema.SwarmLicense, as: SwarmLicense
  alias Edge.Init, as: Edge
  alias Schema.User, as: User
  alias Schema.Swarm, as: Swarm

  @all_fields [
    :id,
    :swarm_license
  ]

  @flat_fields [
    :id
  ]

  @embedded_fields [
    :swarm_license
  ]

  @required_fields [
    :swarm_license
  ]

  require Logger

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    embeds_one(:swarm_license, SwarmLicense)
  end

  def changeset(%Payload{} = struct, params) do
    struct
    |> cast(params, @flat_fields)
    |> cast_embed(:swarm_license, with: &SwarmLicense.changeset/2)
    |> validate_required(@required_fields)
  end


end

