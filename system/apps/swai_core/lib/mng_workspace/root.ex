defmodule MngWorkspace.Root do
  @moduledoc """
  The Aggregate Root for a Workspace.
  """
  use Ecto.Schema
  require Jason

  alias MngHive.Root, as: Hive
  alias MngStation.Root, as: Station

  import Ecto.Changeset


  @all_fields [
    :user_id,
    :stations,
    :hives
  ]



  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field :user_id, :binary_id
    embeds_many(:stations, Station)
    embeds_many(:hives, Hive)
  end


  def changeset(root, attrs) do
    root
    |> cast(attrs, @all_fields)
    |> cast_embed(:stations, with: &Station.changeset/2)
    |> cast_embed(:hives, with: &Hive.changeset/2)
    |> validate_required(@all_fields)
  end





end
