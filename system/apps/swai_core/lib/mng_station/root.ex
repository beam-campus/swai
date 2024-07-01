defmodule MngStation.Root do
  @moduledoc """
  The Aggregate Root for a Station.
  """
  use Ecto.Schema
  import Ecto.Changeset

  require Jason

  alias Edge.Init, as: Producer

  @all_fields [
    :id,
    :name,
    :description,
    :user_id,
    :station_type
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:id, :binary_id)
    field(:name, :string)
    field(:description, :string)
    field(:user_id, :binary_id)
    field(:station_type, :string)
    embeds_one(:producer, Producer)
  end

  def changeset(root, attrs) do
    root
    |> cast(attrs, @all_fields)
    |> cast_embed(:producers, with: &Producer.changeset/2)
    |> validate_required(@all_fields)
  end

  def from_map(map) when is_map(map) do
    case(changeset(%MngStation.Root{}, map)) do
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
