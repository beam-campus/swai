defmodule Scape.Init do
  @moduledoc """
  Scape.InitParams is a struct that holds the parameters for initializing a scape.
  """
  use Ecto.Schema

  import Ecto.Changeset
  require MnemonicSlugs
  require Jason.Encoder
  require Logger

  alias Scape.Init, as: ScapeInit
  alias Scape.Status, as: ScapeStatus

  @all_fields [
    :scape_id,
    :scape_no,
    :hives_cap,
    :particles_cap,
    :edge_id,
    :biotope_id,
    :algorithm_id,
    :scape_status,
    :scape_name,
    :biotope_name,
    :image_url,
    :theme,
    :tags,
    :algorithm_name,
    :algorithm_acronym
  ]

  @flat_fields [
    :scape_id,
    :scape_no,
    :hives_cap,
    :particles_cap,
    :edge_id,
    :biotope_id,
    :algorithm_id,
    :scape_status,
    :scape_name,
    :biotope_name,
    :image_url,
    :theme,
    :tags,
    :algorithm_name,
    :algorithm_acronym
  ]

  @required_fields [
    :scape_id,
    :scape_no,
    :hives_cap,
    :particles_cap,
    :edge_id,
    :biotope_id,
    :algorithm_id,
    :scape_status,
    :has_vacancy?
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:scape_id, :string, default: "scape-#{UUID.uuid4()}")
    field(:scape_no, :integer)
    field(:hives_cap, :integer)
    field(:particles_cap, :integer)
    field(:edge_id, :string)
    field(:biotope_id, :binary_id)
    field(:algorithm_id, :binary_id)
    field(:scape_status, :integer, default: ScapeStatus.unknown())
    field(:has_vacancy?, :boolean, default: true)
    field(:scape_name, :string)
    field(:biotope_name, :string)
    field(:image_url, :string)
    field(:theme, :string)
    field(:tags, :string)
    field(:algorithm_name, :string)
    field(:algorithm_acronym, :string)
  end

  def changeset(%ScapeInit{} = seed, %{} = args)
      when is_struct(args),
      do: changeset(seed, Map.from_struct(args))

  def changeset(%ScapeInit{} = seed, args)
      when is_map(args) do
    seed
    |> cast(args, @flat_fields)
    |> validate_required(@required_fields)
  end

  def from_map(%ScapeInit{} = seed, map) do
    case(changeset(seed, map)) do
      %{valid?: true} = changeset ->
        {:ok, apply_changes(changeset)}

      changeset ->
        Logger.error("Failed to create Scape.Init:
        #{inspect(changeset)}
        ")
        {:error, changeset}
    end
  end

  defp random_scape_name(),
    do: "scape_" <> MnemonicSlugs.generate_slug(2)

  def new(scape_no, edge_init) do
    %ScapeInit{
      scape_id: "scape-#{UUID.uuid4()}",
      scape_no: scape_no,
      scape_name: random_scape_name()
    }
    |> from_map(edge_init)
  end
end
