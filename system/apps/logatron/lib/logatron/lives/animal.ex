defmodule Logatron.Born2Dieds.Animal do
  use Ecto.Schema

  @moduledoc """
  The Life State are the parameters
  that are used as the state structure for a Life Worker
  """
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "born_2_dieds" do
    field :name, :string
    field :status, :string
    field :y, :integer
    field :x, :integer
    field :z, :integer
    field :edge_id, :string
    field :scape_id, :string
    field :region_id, :string
    field :farm_id, :string
    field :field_id, :string
    field :life_id, :string
    field :gender, :string
    field :father_id, :string
    field :mother_id, :string
    field :birth_date, :date
    field :age, :integer
    field :weight, :integer
    field :energy, :integer
    field :is_pregnant, :boolean, default: false
    field :heath, :integer
    field :health, :integer

    timestamps()
  end

  @doc false
  def changeset(animal, attrs) do
    animal
    |> cast(attrs, [:id, :edge_id, :scape_id, :region_id, :farm_id, :field_id, :status, :life_id, :name, :gender, :father_id, :mother_id, :birth_date, :age, :weight, :energy, :is_pregnant, :heath, :health, :x, :y, :z])
    |> validate_required([:id, :edge_id, :scape_id, :region_id, :farm_id, :field_id, :status, :life_id, :name, :gender, :father_id, :mother_id, :birth_date, :age, :weight, :energy, :is_pregnant, :heath, :health, :x, :y, :z])
  end
end
