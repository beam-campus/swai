defmodule Particle.Init do
  @moduledoc """
  This module is responsible for managing the particles in the system.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Particle.Init, as: ParticleInit
  alias Schema.Vector, as: Vector

  require Logger
  require Jason.Encoder

  @all_fields [
    :id,
    :position,
    :momentum,
    :orientation
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:id, :binary_id, primary_key: true, default: UUID.uuid4())
    field(:age, :integer, default: 0)
    field(:health, :integer, default: 100)
    field(:energy, :integer, default: 100)
    embeds_one(:position, Vector)
    embeds_one(:momentum, Vector)
    embeds_one(:orientation, Vector)
  end
end
