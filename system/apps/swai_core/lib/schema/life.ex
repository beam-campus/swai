defmodule Schema.Life do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Schema.Life is the module that contains the Ecto data definition
  for a ver
  """
  require Logger

  alias Schema.Id, as: Id
  alias Schema.Life, as: Life
  alias Schema.LifeNames, as: LifeNames


  @genders [
    "male",
    "female",
    "female",
    "female"
  ]

  @all_fields [
    :id,
    :name,
    :gender,
    :birth_date,
    :father_id,
    :mother_id
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:gender, :string)
    field(:birth_date, :date)
    field(:father_id, :string)
    field(:mother_id, :string)
  end

  @cast_fields [
    :id,
    :name,
    :gender,
    :birth_date,
    :father_id,
    :mother_id
  ]

  def id_prefix, do: "life"

  def changeset(life, attr) do
    life
    |> cast(attr, @cast_fields)
    |> validate_required([:gender])
  end

  def from_map(%{} = attr) when is_map(attr) do
    id = Id.new(id_prefix()) |> Id.as_string()

    case changeset(%Life{id: id}, attr) do
      %{valid?: true} = changeset ->
        life =
          changeset
          |> Ecto.Changeset.apply_changes()

        {:ok, life}

      changeset ->
        {:error, changeset}
    end
  end

  def random do
    gender = Enum.random(@genders)
    %Life{
      id: Id.new(id_prefix()) |> Id.as_string(),
      name: LifeNames.random_name(gender),
      gender: gender,
      birth_date: NaiveDateTime.utc_now(),
      father_id: "unknown",
      mother_id: "unknown"
    }
  end

  def from_calving(calving) do
    gender = Enum.random(@genders)
    %Life{
      id: Id.new(id_prefix()) |> Id.as_string(),
      name: LifeNames.random_name(gender),
      gender: gender,
      birth_date: calving.calving_date,
      father_id: calving.father_id,
      mother_id: calving.mother_id
    }
  end


  defimpl String.Chars, for: Schema.Life do
    def to_string(s) do
      "\n\n [Life]" <>
        "\n\t id: \t #{s.id} \t name: \t #{s.name}" <>
        "\n\t f_id: \t #{s.father_id} \t m_id: \t #{s.mother_id}" <>
        "\n\t gender: \t #{s.gender} \t dob: \t #{s.birth_date}"
    end
  end
end
