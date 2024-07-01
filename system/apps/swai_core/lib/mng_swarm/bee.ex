defmodule MngSwarm.Bee do

  @moduledoc """
  The Bee Schema.
  """

  use Ecto.Schema
  require Jason

  @all_fields [
    :id,
    :swarm_id,
    :name,
    :description
  ]

  @required_fields [
    :id,
    :swarm_id,
  ]

  import Ecto.Changeset



  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field :id, :binary_id
    field :swarm_id, :binary_id
    field :name, :string
    field :description, :string
  end


  def changeset(bee, attrs) do
    bee
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
  end



end
