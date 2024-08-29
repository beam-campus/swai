defmodule Scape.Facts do
  @moduledoc """
  Scape.Facts contains the facts for the Scape subsystem.`
  """

  def scape_facts, do: "scape_facts"

  def scape_queued_v1, do: "scape_queued_v1"

  def initializing_scape_v1, do: "initializing_scape_v1"
  def scape_initialized_v1, do: "scape_initialized_v1"
  def scape_started_v1, do: "scape_started_v1"
  def scape_attached_v1, do: "scape_attached_v1"
  def scape_detached_v1, do: "scape_detached_v1"
  def scape_paused_v1, do: "scape_paused_v1"
  def scape_cancelled_v1, do: "scape_cancelled_v1"
  def scape_completed_v1, do: "scape_completed_v1"

  def scapes_cache_updated_v1, do: "scapes_cache_updated_v1"

end
