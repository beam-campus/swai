defmodule Logatron.Schema.Calving do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Logatron.Schema.Birth contains the Ecto schema for births of calves.
  """
  alias Logatron.Schema.Calving
  alias Schema.Id

  @all_fields [
    :id,
    :mother_id,
    :father_id,
    :calving_date,
    :remarks,
    :dryoff_date,
    :lac_number
  ]

  @required_fields [
    :id,
    :mother_id,
    :father_id,
    :calving_date
  ]



  @prefix "calving"

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:id, :string)
    field(:mother_id, :string)
    field(:father_id, :string)
    field(:calving_date, :date)
    field(:remarks, :string)
    field(:dryoff_date, :date)
    field(:lac_number, :integer)
  end

  def id_prefix, do: "calving"

  def changeset(calving, attrs) do
    calving
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
  end

  def from_map(attrs) do
    case changeset(%Calving{}, attrs) do
      %{valid?: true} = changeset ->
        calving =
          changeset
          |> Ecto.Changeset.apply_changes()
          |> Map.put(:id, Id.new(id_prefix()))

        {:ok, calving}

      changeset ->
        {:error, changeset}
    end
  end
end
