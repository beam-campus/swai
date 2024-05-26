defmodule LogatronCore.Schema.FieldCell do
  use Ecto.Schema

  @moduledoc """
  LogatronCore.Schema.FieldCell is the module that contains the field cell schema
  """

  alias Schema.Id
  # alias Schema.Vector

  import Ecto.Changeset

  @all_fields [
    :id,
    :name,
    :contents
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field :id, :string
    field :name, :string
    field :contents, {:array, :any}
  end


  def new(id, name, contents) do
    %LogatronCore.Schema.FieldCell{
      id: id,
      name: name,
      contents: contents
    }
  end

  def new()
  do
    new(Id.new("cell"), "a cell", [])
  end




  def changeset(field_cell, attr) do
    field_cell
    |> cast(attr, @all_fields)
    |> validate_required(@all_fields)
  end




end
