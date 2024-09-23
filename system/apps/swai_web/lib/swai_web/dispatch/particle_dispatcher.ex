defmodule SwaiWeb.ParticleDispatcher do
  @moduledoc false

  alias Particle.Facts, as: ParticleFacts
  alias Particle.Init, as: ParticleInit
  alias Phoenix.PubSub, as: PubSub

  @particle_facts ParticleFacts.particle_facts()
  @particle_initialized_v1 ParticleFacts.particle_initialized_v1()

  def pub_particle_initialized(envelope) do
    {:ok, particle} = 
      ParticleInit.from_map(%ParticleInit{}, envelope["particle_init"])

    Swai.PubSub
    |> PubSub.broadcast(@particle_facts, {:particle, @particle_initialized_v1, particle})
  end
end
