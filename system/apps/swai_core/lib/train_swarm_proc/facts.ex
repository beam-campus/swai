defmodule TrainSwarmProc.Facts do
  def initialized, do: "swarm_training_initialized"
  def configured, do: "swarm_training_configured"
  def started, do: "swarm_training_started"
  def paused, do: "swarm_training_paused"
  def cancelled, do: "swarm_training_cancelled"
  def completed, do: "swarm_training_completed"
  def activated, do: "swarm_training_activated"
  def deactivated, do: "swarm_training_deactivated"
  def cache_updated_v1, do: "swarm_trainings_cache_updated_v1"
end
