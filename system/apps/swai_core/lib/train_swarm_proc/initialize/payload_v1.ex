defmodule TrainSwarmProc.Initialize.Payload.V1 do
  @moduledoc """
  Cmd module for initializing the swarm training process.
  """
  use Ecto.Schema

  # alias Edge.Init, as: EdgeInit
  alias TrainSwarmProc.Initialize.Payload.V1,
    as: TrainingInit

  @all_fields [
    :swarm_id,
    :user_id,
    :biotope_id,
    :biotope_name,
    :scape_id
  ]

  @flat_fields [
    :swarm_id,
    :user_id,
    :biotope_id,
    :biotope_name
  ]

  @required_fields [
    :swarm_id,
    :user_id,
    :biotope_id,
    :biotope_name,
    :scape_id
  ]

  require Logger
  require Jason

  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:swarm_id, :binary_id, default: UUID.uuid4())
    field(:user_id, :binary_id)
    field(:biotope_id, :binary_id)
    field(:biotope_name, :string)
    field(:scape_id, :string)
  end

  def changeset(%TrainingInit{} = struct, params) do
    changes =
      struct
      |> cast(params, @flat_fields)
      |> validate_required(@required_fields)

    # Logger.alert("Changeset: #{inspect(changes)}")
    changes
  end

  def new(user_id, biotope_id, biotope_name) do
    %TrainingInit{
      user_id: user_id,
      biotope_id: biotope_id,
      biotope_name: biotope_name
    }
  end

  def from_map(%{} = map) do
    struct = %TrainingInit{}

    case changeset(struct, map) do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
