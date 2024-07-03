defmodule TrainSwarm.ConfigureSwarm.Cmd do
  @moduledoc """
  Cmd module for configuring the swarm training process.
  """
  use Ecto.Schema

  alias Schema.Swarm, as: Swarm
  alias Edge.Init, as: EdgeInit
  alias Schema.Biotope, as: Biotope
  alias Schema.User, as: User
  alias Schema.SwarmLicense, as: SwarmLicense



  alias TrainSwarm.ConfigureSwarm.Cmd, as: ConfigureSwarmTraining

  alias TrainSwarm.ConfigureSwarm.Payload, as: Payload

  @all_fields [
    :id,
    :payload
  ]

  @flat_fields [
    :id
  ]

  @embedded_fields [
    :payload
  ]

  @required_fields [
    :payload
  ]

  require Logger

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    embeds_one(:payload, Payload)
  end

  def changeset(%ConfigureSwarmTraining{} = struct, params) do
    struct
    |> cast(params, @flat_fields)
    |> cast_embed(:payload, with: &Payload.changeset/2)
    |> validate_required(@required_fields)
  end

  def from_map(map) do
    struct = %ConfigureSwarmTraining{}
    case changeset(struct, map) do
      %{valid?: true} = changeset ->
        res =
          changeset
          |> apply_changes()

        {:ok, res}

      {:error, changeset} ->
        Logger.error("Failed to cast map to changeset: #{inspect(changeset)}")
        {:error, changeset}
    end
  end

  def from(%SwarmLicense{} = swarm_license) do
    payload = %Payload{
      swarm_license: swarm_license
    }
    %ConfigureSwarmTraining{
      payload: payload
    }
  end
end
