defmodule Swai.Repo.Migrations.CreateSwarmTrainings do
  use Ecto.Migration

  def change do
    create table(:swarm_trainings, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:swarm_id, :binary_id)
      add(:swarm_size, :integer)
      add(:nbr_of_generations, :integer)
      add(:drone_depth, :integer)
      add(:generation_epoch_in_minutes, :integer)
      add(:select_best_count, :integer)
      add(:cost_in_tokens, :integer)
      add(:tokens_used, :integer)
      add(:status, :integer)
      add(:total_run_time_in_seconds, :integer)
      add(:budget_in_tokens, :integer)
      add(:user_id, :binary_id)
      add(:biotope_id, :binary_id)
      add(:biotope_name, :string)
      timestamps(type: :utc_datetime_usec)
    end

    create(index(:swarm_trainings, [:user_id]))
    create(index(:swarm_trainings, [:biotope_id]))
  end
end
