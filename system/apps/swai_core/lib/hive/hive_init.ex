defmodule Hive.Init do
  use Ecto.Schema

  @moduledoc """
  Hive.Init is the struct that identifies the state of a Region.
  """
  import Ecto.Changeset

  alias Hive.Init, as: HiveInit
  alias Schema.Vector, as: Vector
  alias Scape.Init, as: ScapeInit

  require Logger
  require Jason.Encoder

  @all_fields [
    :hive_id,
    :particles_cap,
    :edge_id,
    :scape_id,
    :hive_no,
    :license_id,
    :location,
    :scape_name
  ]

  @flat_fields [
    :hive_id,
    :particles_cap,
    :edge_id,
    :scape_id,
    :hive_no,
    :license_id,
    :scape_name
  ]

  @required_fields [
    :hive_id,
    :particles_cap,
    :edge_id,
    :scape_id,
    :hive_no,
    :location
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    # HiveInit ID
    field(:hive_id, :string, default: "hive-#{UUID.uuid4()}")
    field(:particles_cap, :integer)
    field(:edge_id, :string)
    field(:scape_id, :string)
    field(:hive_no, :integer)
    field(:license_id, :binary_id, default: nil)
    field(:scape_name, :string)
    embeds_one(:location, Vector, on_replace: :delete)
  end

  def changeset(seed, struct)
      when is_struct(struct),
      do: changeset(seed, Map.from_struct(struct))

  def changeset(%HiveInit{} = seed, attrs)
      when is_map(attrs) do
    seed
    |> cast(attrs, @flat_fields)
    |> cast_embed(:location)
    |> validate_required(@required_fields)
  end

  def from_map(%HiveInit{} = seed, map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        Logger.error("Failed to create HiveInit from map: #{inspect(map)}")
        {:error, changeset}
    end
  end

  def new(hive_no, %ScapeInit{} = scape_init) do
    seed =
      %HiveInit{
        hive_id: "hive-#{UUID.uuid4()}",
        hive_no: hive_no,
        location: get_hive_location(hive_no)
      }
      |> from_map(scape_init)
  end

  def is_occupied?(%HiveInit{license_id: nil}), do: false
  def is_occupied?(%HiveInit{license_id: _}), do: true

  def is_vacant?(%HiveInit{license_id: nil}), do: true
  def is_vacant?(_), do: false

  defp get_hive_location(1), do: %Vector{x: 100, y: 100, z: 0}
  defp get_hive_location(2), do: %Vector{x: 800 - 100, y: 100, z: 0}
  defp get_hive_location(3), do: %Vector{x: 800 - 100, y: 600 - 100, z: 0}
  defp get_hive_location(4), do: %Vector{x: 100, y: 600 - 100, z: 0}
  defp get_hive_location(5), do: %Vector{x: 100 + 300, y: 100, z: 0}
  defp get_hive_location(6), do: %Vector{x: 100 + 300, y: 600 - 100, z: 0}
  defp get_hive_location(_), do: nil
end
