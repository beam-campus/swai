defmodule TrainSwarmProc.Facts do
  def license_initialized, do: "swarm_license_initialized"
  def license_configured, do: "swarm_license_configured"
  def license_paid, do: "swarm_license_paid"
  def license_activated, do: "swarm_license_activated"
  def license_deactivated, do: "swarm_license_deactivated"
  def license_blocked, do: "swarm_license_blocked"

  def scape_queued, do: "scape_queued"
  def scape_started, do: "scape_started"
  def scape_paused, do: "scape_paused"
  def scape_cancelled, do: "scape_cancelled"
  def scape_completed, do: "scape_completed"

  def cache_updated_v1, do: "swarm_licenses_cache_updated_v1"
end
