defmodule Swai.Repo.Migrations.CreateBiotopes do
  use Ecto.Migration

  def change do
    create table(:biotopes, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:description, :text)
      add(:image_url, :string)
      add(:theme, :string)
      add(:tags, :string)
      add(:objective, :string)
      add(:environment, :text)
      add(:challenges, :text)
      add(:difficulty, :integer)
      add(:is_active?, :boolean, default: false)
      add(:biotope_type, :string, default: "Swarm vs Environment")
      add(:is_realistic?, :boolean, default: false)
      timestamps(type: :utc_datetime_usec)
    end
  end
end
