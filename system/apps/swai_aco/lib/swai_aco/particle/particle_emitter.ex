defmodule Particle.Emitter do
  @moduledoc false

  alias Particle.Facts, as: ParticleFacts
  alias Particle.Init, as: Particle
  alias Edge.Client, as: EdgeClient

  @particle_initialized_v1 ParticleFacts.particle_initialized_v1()

  def emit_particle_initialized(%Particle{edge_id: edge_id} = particle) do
    EdgeClient.publish(
      edge_id,
      @particle_initialized_v1,
      %{particle_init: particle}
    )
  end
end
