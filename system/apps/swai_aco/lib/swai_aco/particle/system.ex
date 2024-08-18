defmodule SwaiAco.Particle.System do
  @moduledoc """
  This module is responsible for managing the particles in the system.
  """
  use GenServer

  alias Particle.Init, as: ParticleInit
  alias Swai.Registry, as: Registry

  @impl true
  def init(%ParticleInit{} = particle_init) do
    {:ok, particle_init}
  end

  ################### PLUMBING ###################
  def to_name(particle_id),
    do: "region.system.#{particle_id}"

  def via(key),
    do: Registry.via_tuple({:particle_sys, to_name(key)})

  def via_sup(key),
    do: Registry.via_tuple({:particle_sup, to_name(key)})

  def child_spec(%{id: particle_id} = particle_init) do
    %{
      id: to_name(particle_id),
      start: {__MODULE__, :start_link, [particle_init]},
      type: :supervisor,
      restart: :transient
    }
  end

  def which_children(particle_id) do
    Supervisor.which_children(via_sup(particle_id))
  end

  def start_link(%{id: particle_id} = particle_init),
    do:
      GenServer.start_link(
        __MODULE__,
        particle_init,
        name: via(particle_id)
      )
end
