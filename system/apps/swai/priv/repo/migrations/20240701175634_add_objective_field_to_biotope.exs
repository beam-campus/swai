defmodule Swai.Repo.Migrations.AddObjectiveFieldToBiotope do
  use Ecto.Migration

  def change do
    alter table(:biotopes) do
      add(:objective, :string)
      add(:environment, :text)
      add(:challenges, :text)
      add(:difficulty, :integer)
      add(:is_active?, :boolean, default: false)
      add(:biotope_type, :string, default: "Swarm vs Environment")
      add(:is_realistic?, :boolean, default: false)
    end
  end
end
