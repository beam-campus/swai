defmodule TrainSwarm.Initialize.Cmd do
  @moduledoc """
  Cmd module for initializing the swarm training process.
  """
  use Ecto.Schema

  alias Edge.Init, as: EdgeInit
  alias Schema.Biotope, as: Biotope
  alias Schema.User, as: User
  alias TrainSwarm.Initialize.Cmd, as: InitializeSwarmTraining

  @all_fields [
    :id,
    :user,
    :biotope,
    :edge
  ]

  @flat_fields [
    :id
  ]

  @embedded_fields [
    :user,
    :biotope,
    :edge
  ]

  @required_fields [
    :user,
    :biotope,
    :edge
  ]

  require Logger
  require Jason

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    embeds_one(:user, User)
    embeds_one(:biotope, Biotope)
    embeds_one(:edge, EdgeInit)
  end

  def changeset(%InitializeSwarmTraining{} = struct, params) do
    struct
    |> cast(params, @flat_fields)
    |> cast_embed(:user, with: &User.changeset/2)
    |> cast_embed(:biotope, with: &Biotope.changeset/2)
    |> cast_embed(:edge, with: &EdgeInit.changeset/2)
    |> validate_required(@required_fields)
  end

  def from_map(map) do
    struct = %InitializeSwarmTraining{}
    case changeset(struct, map) do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}
      changeset ->
        {:error, changeset}
    end

  end

end
