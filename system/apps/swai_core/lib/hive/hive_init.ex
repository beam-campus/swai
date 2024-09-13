defmodule Hive.Init do
  use Ecto.Schema

  @moduledoc """
  Hive.Init is the struct that identifies the state of a Region.
  """
  import Ecto.Changeset

  alias Arena.Hexa, as: Hexa
  alias Hive.Init, as: HiveInit
  alias Hive.Status, as: HiveStatus
  alias Scape.Init, as: ScapeInit
  alias Scape.Utils, as: ScapeUtils
  alias Schema.SwarmLicense, as: License

  require Logger
  require Jason.Encoder

  @hive_status_unknown HiveStatus.unknown()

  @all_fields [
    :hive_id,
    :hive_name,
    :particles_cap,
    :hive_status,
    :edge_id,
    :scape_id,
    :biotope_id,
    :hive_no,
    :license_id,
    :scape_name,
    :hexa,
    :license
  ]

  @flat_fields [
    :hive_id,
    :hive_name,
    :particles_cap,
    :hive_status,
    :edge_id,
    :scape_id,
    :biotope_id,
    :hive_no,
    :license_id,
    :scape_name
  ]

  @required_fields [
    :hive_id,
    :particles_cap,
    :edge_id,
    :scape_id,
    :biotope_id,
    :hive_no,
    :hexa
  ]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    # HiveInit ID
    field(:hive_id, :string, default: "hive-#{UUID.uuid4()}")
    field(:hive_status, :integer, default: @hive_status_unknown)
    field(:particles_cap, :integer)
    field(:hive_name, :string)
    field(:edge_id, :string)
    field(:scape_id, :string)
    field(:biotope_id, :string)
    field(:hive_no, :integer, default: 1)
    field(:license_id, :binary_id, default: nil)
    field(:scape_name, :string)
    embeds_one(:hexa, Hexa, on_replace: :delete)
    embeds_one(:license, License, on_replace: :delete)
  end

  def changeset(seed, struct)
      when is_struct(struct),
      do: changeset(seed, Map.from_struct(struct))

  def changeset(seed, attrs)
      when is_map(attrs) do
    seed
    |> cast(attrs, @flat_fields)
    |> cast_embed(:license, with: &License.changeset/2)
    |> cast_embed(:hexa, with: &Hexa.changeset/2)
    |> validate_required(@required_fields)
  end

  def from_map(seed, map) do
    case changeset(seed, map) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        Logger.error("Failed to create HiveInit from map: #{inspect(map)}")
        {:error, changeset}
    end
  end

  def default,
    do: %HiveInit{
      hive_id: "hive-#{UUID.uuid4()}",
      hive_status: @hive_status_unknown,
      particles_cap: 0,
      edge_id: "N/A",
      scape_id: "N/A",
      biotope_id: UUID.uuid4(),
      hive_no: 1,
      hive_name: "N/A",
      license_id: nil,
      scape_name: "N/A",
      hexa: nil,
      license: nil
    }

  def new(hive_no, %ScapeInit{scape_name: scape_name} = scape_init) do
    %HiveInit{
      hive_id: "hive-#{UUID.uuid4()}",
      hive_no: hive_no,
      hexa: ScapeUtils.get_hive_hexa(hive_no),
      hive_status: @hive_status_unknown,
      hive_name: "#{scape_name}-#{hive_no}"
    }
    |> from_map(scape_init)
  end

  def occupied?(%HiveInit{license_id: nil}), do: false
  def occupied?(%HiveInit{license_id: _}), do: true

  def vacant?(%HiveInit{license_id: nil}), do: true
  def vacant?(_), do: false
end
