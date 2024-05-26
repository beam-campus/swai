defmodule Logatron.Schema.Edge do
  use Ecto.Schema

  @moduledoc """
  Logatron.Schema.Edge contains the Ecto schema for the edge.
  """

  import Ecto.Changeset

  alias Logatron.Schema.Edge, as: Edge
  alias Schema.Id, as: Id

  @all_fields [
    :id,
    :ip_address,
    :whois
  ]

  @required_fields [:id]

  def id_prefix, do: "edge"

  @primary_key false
  embedded_schema do
    field :id, :string
    field :ip_address, :string
    field :whois, :string
  end

  def random_id() do
    Id.new(id_prefix())
    |> Id.as_string()
  end

  def random() do
    %Edge{
      id: random_id()
    }
  end

  def changeset(edge, args)
      when is_map(args) do
    edge
    |> cast(args, @all_fields)
    |> validate_required(@required_fields)

  end


end
