defmodule Scape.Init do
  @moduledoc """
  Scape.InitParams is a struct that holds the parameters for initializing a scape.
  """
  use Ecto.Schema

  import Ecto.Changeset
  require MnemonicSlugs
  require Jason.Encoder

  alias Scape.Init, as: ScapeInit
  alias Schema.SwarmLicense, as: License
  alias Schema.SwarmLicense.Status, as: LicenseStatus
  alias Edge.Init, as: EdgeInit

  alias Schema.Vector, as: Vector

  @all_fields [
    :id,
    :edge_id,
    :name,
    :license_id,
    :swarm_id,
    :swarm_name,
    :swarm_size,
    :swarm_time_min,
    :user_id,
    :biotope_id,
    :biotope_name,
    :image_url,
    :theme,
    :tags,
    :algorithm_id,
    :algorithm_name,
    :algorithm_acronym,
    :dimensions,
    :edge
  ]

  @flat_fields [
    :id,
    :edge_id,
    :name,
    :license_id,
    :swarm_id,
    :swarm_name,
    :swarm_size,
    :swarm_time_min,
    :user_id,
    :biotope_id,
    :biotope_name,
    :image_url,
    :theme,
    :tags,
    :algorithm_id,
    :algorithm_name,
    :algorithm_acronym
  ]

  @required_fields [
    :id,
    :license_id,
    :swarm_id,
    :swarm_name,
    :swarm_size,
    :swarm_time_min,
    :user_id,
    :biotope_id,
    :algorithm_acronym,
    :dimensions
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:id, :binary_id, default: UUID.uuid4())
    field(:edge_id, :binary_id)

    field(:name, :string,
      default: ("scape_" <> MnemonicSlugs.generate_slug(2)) |> String.replace("-", "_")
    )

    field(:license_id, :binary_id)
    field(:status, :integer, default: LicenseStatus.unknown())
    field(:swarm_id, :binary)
    field(:swarm_name, :string)
    field(:swarm_size, :integer, default: 100)
    field(:swarm_time_min, :integer, default: 60)
    field(:user_id, :binary_id)
    field(:biotope_id, :binary_id)
    field(:biotope_name, :string)
    field(:image_url, :string)
    field(:theme, :string)
    field(:tags, :string)
    field(:algorithm_id, :binary_id)
    field(:algorithm_name, :string)
    field(:algorithm_acronym, :string)
    embeds_one(:dimensions, Vector, on_replace: :delete)
    embeds_one(:license, License, on_replace: :delete)
    embeds_one(:edge, EdgeInit, on_replace: :delete)
  end


  def test_scape_init() do
    license_id = UUID.uuid4()
    scape_id = UUID.uuid4()
    edge_id = UUID.uuid4()
    user_id = UUID.uuid4()
    biotope_id = UUID.uuid4()
    algorithm_id = UUID.uuid4()
    swarm_id = UUID.uuid4()

    map = %{
      id: scape_id,
      edge_id: edge_id,
      license_id: license_id,
      swarm_id: swarm_id,
      swarm_name: "swarm_name",
      swarm_size: 100,
      swarm_time_min: 60,
      user_id: user_id,
      biotope_id: biotope_id,
      biotope_name: "biotope_name",
      image_url: "image_url",
      theme: "theme",
      tags: "tags",
      algorithm_id: algorithm_id,
      algorithm_name: "algorithm_name",
      algorithm_acronym: "algorithm_acronym",
      dimensions: %{
        x: 800,
        y: 600,
        z: 0
      },
      license: %{
        status: LicenseStatus.unknown(),
        license_id: license_id,
        swarm_id: swarm_id,
        swarm_name: "swarm_name",
        swarm_size: 100,
        swarm_time_min: 60,
        user_id: user_id,
        biotope_id: biotope_id,
        biotope_name: "biotope_name",
        image_url: "image_url",
        theme: "theme",
        tags: "tags",
        algorithm_id: algorithm_id,
        algorithm_name: "algorithm_name",
        algorithm_acronym: "algorithm_acronym",
        dimensions: %{
          x: 800,
          y: 600,
          z: 0
        }
      }
    }
    case from_map(%ScapeInit{}, map) do
      {:ok, scape_init} ->
        IO.puts("Scape.Init test_scape_init() OK")
        scape_init
      {:error, error} ->
        IO.puts("Scape.Init test_scape_init() ERROR! => #{inspect(error)}")
    end
  end

  def changeset(%ScapeInit{} = seed, %{} = args) when is_struct(args),
    do: changeset(seed, Map.from_struct(args))

  def changeset(%ScapeInit{} = seed, args) when is_map(args) do
    seed
    |> cast(args, @flat_fields)
    |> cast_embed(:dimensions, with: &Vector.changeset/2, force_update_on_change: false)
    |> cast_embed(:license, with: &License.changeset/2, force_update_on_change: false)
    |> cast_embed(:edge, with: &EdgeInit.changeset/2, force_update_on_change: false)
    |> validate_required(@required_fields)
  end

  def from_map(%ScapeInit{} = seed, map) when is_struct(map),
    do: from_map(seed, Map.from_struct(map))

  def from_map(%ScapeInit{} = seed, map) when is_map(map) do
    case(changeset(seed, map)) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
