defmodule Logatron.Repo.Migrations.CreateBorn2Dieds do
  use Ecto.Migration

  def change do
    create table(:born_2_dieds, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :edge_id, :string
      add :scape_id, :string
      add :region_id, :string
      add :farm_id, :string
      add :field_id, :string
      add :status, :string
      add :life_id, :string
      add :name, :string
      add :gender, :string
      add :father_id, :string
      add :mother_id, :string
      add :birth_date, :date
      add :age, :integer
      add :weight, :integer
      add :energy, :integer
      add :is_pregnant, :boolean, default: false, null: false
      add :heath, :integer
      add :health, :integer
      add :x, :integer
      add :y, :integer
      add :z, :integer

      timestamps()
    end
  end
end
