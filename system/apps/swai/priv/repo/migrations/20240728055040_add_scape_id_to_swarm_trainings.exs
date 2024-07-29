defmodule Swai.Repo.Migrations.AddScapeIdToSwarmTrainings do
  use Ecto.Migration

  def change do
    alter table(:swarm_trainings) do
      add(:scape_id, :string)
    end
  end
end
