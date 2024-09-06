defmodule TrainSwarmProc.Facts do
  @moduledoc """
  The facts module for the TrainSwarmProc
  """
  def license_facts, do: "swarm_license_facts"
  def license_initialized, do: "swarm_license_initialized"
  def license_configured, do: "swarm_license_configured"
  def license_paid, do: "swarm_license_paid"
  def license_activated, do: "swarm_license_activated"
  def license_deactivated, do: "swarm_license_deactivated"
  def license_blocked, do: "swarm_license_blocked"
  def license_presented, do: "license_presented"

  def cache_facts, do: "swarm_licenses_cache_facts"
  def cache_updated_v1, do: "swarm_licenses_cache_updated_v1"
end
