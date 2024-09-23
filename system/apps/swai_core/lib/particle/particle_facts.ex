defmodule Particle.Facts do
  @moduledoc """
  The ParticleFacts module is used to store and retrieve data from the Particle ETS cache.
  """
  def particle_facts, do: "particle_facts"
  def particles_cache_facts, do: "particles_cache_facts"

  def particle_initialized_v1, do: "particle_initialized:v1"
  def particle_moved_v1, do: "particle_moved:v1"
  def particle_died_v1, do: "particle_died:v1"
end
