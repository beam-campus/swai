defmodule MngHive.Root do
  @moduledoc """
  The Aggregate Root for a Hive.
  """
  use Ecto.Schema
  require Jason

  import Ecto.Changeset

  alias MngSwarm.Root, as: Swarm
  alias MngHive.Root, as: Hive

  @all_fields [
    :id,
    :user_id,
    :name,
    :description
  ]

  @required_fields [
    :id,
    :user_id
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field :id, :binary_id
    field :user_id, :binary_id
    field :name, :string
    field :description, :string
    embeds_one(:swarm, Swarm)
  end


  def changeset(root, attrs) do
    root
    |> cast(attrs, @all_fields)
    |> cast_embed(:swarm, with: &Swarm.changeset/2)
    |> validate_required(@required_fields)
  end

  def from_map(map) when is_map(map) do
    case(changeset(%Hive{}, map)) do
      %{valid?: true} = changeset ->
        root =
          changeset
          |> Ecto.Changeset.apply_changes()

        {:ok, root}

      changeset ->
        {:error, changeset}
    end
  end



end
