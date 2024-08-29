defmodule Hive.Init do
  use Ecto.Schema

  @moduledoc """
  Hive.Init is the struct that identifies the state of a Region.
  """
  import Ecto.Changeset

  alias Hive.Init, as: HiveInit

  require Logger
  require Jason.Encoder

  @all_fields [
    :edge_id,
    :scape_id,
    :swarm_id,
    :swarm_size,
    :biotope_id,
    :user_id
  ]

  @flat_fields [
    :edge_id,
    :scape_id,
    :swarm_id,
    :swarm_size,
    :biotope_id,
    :user_id
  ]

  @required_fields [
    :edge_id,
    :scape_id,
    :swarm_id,
    :swarm_size,
    :biotope_id,
    :user_id
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:swarm_id, :binary_id)
    field(:edge_id, :binary_id)
    field(:scape_id, :binary_id)
    field(:swarm_size, :integer)
    field(:biotope_id, :binary_id)
    field(:user_id, :binary_id)
  end

  def changeset(seed, struct)
  when is_struct(struct),
    do: changeset(seed, Map.from_struct(struct))

  def changeset(%HiveInit{} = seed, attrs)
  when is_map(attrs) do
    seed
    |> cast(attrs, @flat_fields)
    |> validate_required(@required_fields)
  end

  def from_map(%HiveInit{} = seed, map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        Logger.error("Failed to create HiveInit from map: #{inspect(map)}")
        {:error, changeset}
    end
  end

  

end
