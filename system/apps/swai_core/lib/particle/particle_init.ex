defmodule Particle.Init do
  @moduledoc """
  This module is responsible for managing the particles in the system.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Arena.Hexa, as: Hexa

  alias Hive.Init, as: HiveInit
  alias Schema.Vector, as: Vector

  require Logger
  require Jason.Encoder

  @json_fields [
    :particle_id,
    :license_id,
    :user_id,
    :scape_id,
    :edge_id,
    :hive_id,
    :hive_no,
    :age,
    :health,
    :energy,
    :position,
    :momentum,
    :orientation,
    :hexa
  ]

  @all_fields [
    :particle_id,
    :license_id,
    :user_id,
    :edge_id,
    :scape_id,
    :hive_id,
    :hive_no,
    :hive_color,
    :age,
    :health,
    :energy,
    :position,
    :momentum,
    :orientation,
    :hexa
  ]

  @required_fields [
    :particle_id,
    :license_id,
    :user_id,
    :scape_id,
    :hive_id,
    :hive_no
  ]

  @flat_fields [
    :particle_id,
    :license_id,
    :user_id,
    :edge_id,
    :scape_id,
    :hive_id,
    :hive_no,
    :age,
    :health,
    :energy
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @json_fields}
  embedded_schema do
    field(:particle_id, :binary_id, primary_key: true, default: UUID.uuid4())
    field(:license_id, :binary_id)
    field(:user_id, :binary_id)
    field(:edge_id, :binary_id)
    field(:scape_id, :binary_id)
    field(:hive_id, :binary_id)
    field(:hive_no, :integer, default: 1)
    field(:hive_color, :string, virtual: true)
    field(:age, :integer, default: 0)
    field(:health, :integer, default: 100)
    field(:energy, :integer, default: 100)
    embeds_one(:position, Vector)
    embeds_one(:momentum, Vector)
    embeds_one(:orientation, Vector)
    embeds_one(:hexa, Hexa)
  end

  def calaculate_hive_color(changeset) do
    hive_no =
      changeset
      |> get_field(:hive_no)

    changeset
    |> put_change(:hive_color, HiveInit.get_hive_color(hive_no))
  end

  def changeset(seed, nil),
    do: {:ok, seed}

  def changeset(particle, attrs)
      when is_struct(attrs),
      do: changeset(particle, Map.from_struct(attrs))

  def changeset(particle, attrs) when is_map(attrs) do
    particle
    |> cast(attrs, @flat_fields)
    |> cast_embed(:hexa, with: &Hexa.changeset/2)
    |> cast_embed(:position, with: &Vector.changeset/2)
    |> cast_embed(:momentum, with: &Vector.changeset/2)
    |> cast_embed(:orientation, with: &Vector.changeset/2)
    |> calaculate_hive_color()
    |> validate_required(@required_fields)
  end

  def from_map(seed, attrs) do
    case changeset(seed, attrs) do
      %{valid?: true} = changes ->
        {:ok, apply_changes(changes)}

      {:ok, default} ->
        {:ok, default}

      {:error, changeset} ->
        Logger.error("Failed to create particle: #{inspect(changeset)}")
        {:error, changeset}
    end
  end
end
