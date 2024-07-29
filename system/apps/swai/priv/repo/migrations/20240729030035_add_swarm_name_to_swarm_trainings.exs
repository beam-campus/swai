defmodule Swai.Repo.Migrations.AddSwarmNameToSwarmTrainings do
  use Ecto.Migration

  def change do
    alter table(:swarm_trainings) do
      add(:swarm_name, :string)
    end
  end
end
