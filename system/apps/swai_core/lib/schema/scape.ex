defmodule Swai.Schema.Scape do
  use Ecto.Schema

  @moduledoc """
  Swai.Schema.Scape contains the Ecto schema for the Scape.
  """

  import Ecto.Changeset

  alias Swai.Schema.{Edge, Scape, Id, Region}

  def id_prefix(), do: "scape"

  @all_fields [
    :id,
    :name
  ]

  @required_fields [:name]

  @derive {Jason.Encoder, only: @all_fields}

  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    embeds_many(:sourced_by, Edge)
    embeds_many(:regions, Region)
  end

  def random_id() do
    Id.new(id_prefix())
    |> Id.as_string()
  end

  def changeset(scape, args)
      when is_map(args) do
    scape
    |> cast(args, @all_fields)
    |> cast_embed(:sourced_by,
      with: &Edge.changeset/2
    )
    |> cast_embed(:regions,
      with: &Region.changeset/2
    )
    |> validate_required(@required_fields)
  end

  @doc """
  Scape.new(args) requires an input map that contains:
  1. a name for the Scape
  2. regions: a list of regions for the Scape
  """
  def new(map) when is_map(map) do
    new_id =
      Id.new(id_prefix())
      |> Id.as_string()

    case changeset(%Scape{}, map) do
      %{valid?: true} = changeset ->
        scape =
          changeset
          |> apply_changes()
          |> Map.put(:id, new_id)

        {:ok, scape}

      changeset ->
        {:error, changeset}
    end
  end

  def from_map(map) when is_map(map) do
    case changeset(%Scape{}, map) do
      %{valid?: true} = changeset ->
        scape =
          changeset
          |> apply_changes()
        {:ok, scape}
      changeset ->
        {:error, changeset}
    end
  end


end
