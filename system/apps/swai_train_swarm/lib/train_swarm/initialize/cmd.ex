defmodule TrainSwarmProc.Initialize.Cmd do
  @moduledoc """
  Cmd module for initializing the swarm training process.
  """
  use Ecto.Schema

  alias Edge.Init, as: EdgeInit
  alias Schema.Biotope, as: Biotope
  alias Schema.User, as: User
  alias TrainSwarmProc.Initialize.Cmd, as: RequestLicense

  @all_fields [
    :id,
    :swarm_size,
    :nbr_of_generations,
    :drone_depth,
    :user_id,
    :biotope_id,
  ]

  @flat_fields [
    :id,
    :swarm_size,
    :nbr_of_generations,
    :user_id,
    :biotope_id,
  ]


  @required_fields [
    :id,
    :swarm_size,
    :nbr_of_generations,
    :user_id,
    :biotope_id,
  ]

  require Logger
  require Jason

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:swarm_size, :integer, default: 10)
    field(:nbr_of_generations, :integer, default: 10)
    field(:drone_depth, :integer, default: 10)
    field(:user_id)
    field(:biotope_id)
  end

  def changeset(%RequestLicense{} = struct, params) do
    struct
    |> cast(params, @flat_fields)
    |> validate_required(@required_fields)
  end

  def changeset_from_user_and_biotope(root, user, biotope) do
    Logger.alert("Requesting license to swarm for biotope #{inspect(biotope)} for user #{inspect(user)}")

    map =   %{
      "user_id" => user.id,
      "biotope_id" => biotope.id
    }
    root
    |> cast(map, [:user_id, :biotope_id])
    |> validate_required([:user_id, :biotope_id])
  end

  def new() do
    %RequestLicense{}
  end

  def from_map(map) do
    struct = %RequestLicense{}
    case changeset(struct, map) do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
