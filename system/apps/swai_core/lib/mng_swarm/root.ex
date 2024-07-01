defmodule MngSwarm.Root do
  @moduledoc """
  The Aggregate Root for a Swarm.
  """
  use Ecto.Schema

  require Jason

  alias MngSwarm.Bee, as: Bee

  import Ecto.Changeset

  @all_fields [
    :id,
    :hive_id,
    :user_id,
    :name,
    :description,
    :bees
  ]

  @required_fields [
    :id,
    :hive_id,
    :user_id
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:id, :binary_id)
    field(:hive_id, :binary_id)
    field(:user_id, :binary_id)
    field(:name, :string)
    field(:description, :string)
    embeds_many(:bees, Bee)
  end

  def changeset(root, attrs) do
    root
    |> cast(attrs, @all_fields)
    |> cast_embed(:bees, with: &Bee.changeset/2)
    |> validate_required(@required_fields)
  end

  def from_map(map) when is_map(map) do
    case(changeset(%MngSwarm.Root{}, map)) do
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
