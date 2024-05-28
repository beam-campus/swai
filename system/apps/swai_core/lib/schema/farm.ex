defmodule Schema.Farm do
  @moduledoc """
  Schema.Farm is a schema for a farm.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Schema.Farm
  alias Schema.Id
  alias Schema.Vector, as: Vector

  @cols 20
  @rows 20
  @depth 1
  @max_pct_good 10
  @max_pct_bad 10

  @farm_names [
    "Verstrepen",
    "Degeyter",
    "Koeman",
    "Laitier",
    "Aldono",
    "Balear",
    "Bandana",
    "Buelens",
    "Castella",
    "Charlston",
    "Cantina",
    "Vanzande",
    "Dinga",
    "Donga",
    "Datil",
    "Eanti",
    "Elondo",
    "Fildina",
    "Fungus",
    "Fillo",
    "Gerdin",
    "Golles",
    "Hando",
    "Hundi",
    "Impala",
    "Inco",
    "Ilteri",
    "Julo",
    "Jandi",
    "Kold",
    "Kantra",
    "Kilo",
    "Lodi",
    "Lanka",
    "Mista",
    "Nokila",
    "Omki",
    "Pidso",
    "Quenke",
    "Rondi",
    "Solo",
    "Salto",
    "Tandy",
    "Tonko",
    "Telda",
    "Umpo",
    "Uldin",
    "Verto",
    "Wondi",
    "Xunda",
    "Yzum",
    "Zompi"
  ]

  @farm_entity [
    "NV",
    "SA",
    "Ltd",
    "Spzoo",
    "VoF",
    "BV",
    "EVBA",
    "SPRL",
    "SARL",
    "SAS"
  ]

  @all_fields [
    :id,
    :name,
    :nbr_of_robots,
    :nbr_of_lives,
    :fields_def,
    :max_pct_good,
    :max_pct_bad
  ]

  @cast_fields [
    :id,
    :name,
    :nbr_of_robots,
    :nbr_of_lives,
    :max_pct_good,
    :max_pct_bad
  ]

  @required_fields [
    :id,
    :name,
    :nbr_of_robots,
    :nbr_of_lives,
    :fields_def,
    :max_pct_good,
    :max_pct_bad
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:nbr_of_robots, :integer)
    field(:nbr_of_lives, :integer)
    field(:max_pct_good, :integer)
    field(:max_pct_bad, :integer)
    embeds_one(:fields_def, Vector)
  end

  defp id_prefix,
    do: "farm"

  def changeset(farm, args) do
    farm
    |> cast(args, @cast_fields)
    |> cast_embed(:fields_def, with: &Vector.changeset/2)
    |> validate_required(@required_fields)
  end

  def new(attrs) do
    case changeset(%Farm{}, attrs) do
      %{valid?: true} = changeset ->
        id =
          Id.new(id_prefix())
          |> Id.as_string()

        farm =
          changeset
          |> Ecto.Changeset.apply_changes()
          |> Map.put(:id, id)

        {:ok, farm}

      changeset ->
        {:error, changeset}
    end
  end

  def random_name() do
    Enum.random(@farm_names) <>
      " " <>
      Enum.random(@farm_entity) <>
      " " <>
      to_string(:rand.uniform(Swai.Limits.max_farms()))
  end

  def random do
    name = random_name()

    id =
      Id.new(id_prefix())
      |> Id.as_string()

    %Schema.Farm{
      id: id,
      name: name,
      nbr_of_lives:
        normalize(
          abs(
            :rand.uniform(Swai.Limits.max_lives()) -
              :rand.uniform(Swai.Limits.max_lives() - Swai.Limits.min_lives())
          )
        ),
      nbr_of_robots:
        normalize(
          abs(
            :rand.uniform(Swai.Limits.max_robots()) -
              :rand.uniform(Swai.Limits.max_robots() - Swai.Limits.min_robots())
          )
        ),
      max_pct_good: :rand.uniform(@max_pct_good),
      max_pct_bad: :rand.uniform(@max_pct_bad),
      fields_def: Vector.new(@cols, @rows, @depth)
    }
  end

  defp normalize(res) when res > 0, do: res
  defp normalize(res) when res <= 0, do: 1
end
