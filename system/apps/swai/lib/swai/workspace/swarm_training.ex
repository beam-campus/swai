defmodule Swai.Workspace.SwarmTraining do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "swarm_trainings" do
    field :status, :integer
    field :swarm_size, :integer
    field :nbr_of_generations, :integer
    field :drone_depth, :integer
    field :generation_epoch_in_minutes, :integer
    field :select_best_count, :integer
    field :cost_in_tokens, :integer
    field :tokens_used, :integer
    field :total_run_time_in_seconds, :integer
    field :budget_in_tokens, :integer
    field :user_id, :binary_id
    field :biotope_id, :binary_id

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(swarm_training, attrs) do
    swarm_training
    |> cast(attrs, [:swarm_size, :nbr_of_generations, :drone_depth, :generation_epoch_in_minutes, :select_best_count, :cost_in_tokens, :tokens_used, :status, :total_run_time_in_seconds, :budget_in_tokens])
    |> validate_required([:swarm_size, :nbr_of_generations, :drone_depth, :generation_epoch_in_minutes, :select_best_count, :cost_in_tokens, :tokens_used, :status, :total_run_time_in_seconds, :budget_in_tokens])
  end
end
