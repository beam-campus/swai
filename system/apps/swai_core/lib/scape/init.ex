defmodule Scape.Init do
  @moduledoc """
  Scape.InitParams is a struct that holds the parameters for initializing a scape.
  """
  use Ecto.Schema

  import Ecto.Changeset
  require MnemonicSlugs

  alias Scape.Init, as: ScapeInit
  alias Schema.Scape, as: Scape

  @env_scape_id EnvVars.swai_edge_scape_id()
  @env_scape_name EnvVars.swai_edge_scape_name()
  @env_scape_description EnvVars.swai_edge_scape_description()
  @env_scape_theme EnvVars.swai_edge_scape_theme()
  @env_scape_image_url EnvVars.swai_edge_scape_image_url()

  # @env_scape_select_from EnvVars.Swai_edge_scape_select_from()
  # @env_scape_nbr_of_countries EnvVars.Swai_edge_scape_nbr_of_countries()
  # @env_scape_min_area EnvVars.Swai_edge_scape_min_area()
  # @env_scape_min_people EnvVars.Swai_edge_scape_min_people()

  @all_fields [
    :id,
    :name,
    :description,
    :theme,
    :image_url,
    :edge_id,
    :nbr_of_countries,
    :min_area,
    :min_people,
    :select_from
  ]

  @required_fields [
    :id,
    :name,
    :description,
    :theme,
    :image_url,
    :edge_id,
    :nbr_of_countries,
    :min_area,
    :min_people,
    :select_from
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:edge_id, :string)
    field(:name, :string)
    field(:description, :string, default: "A scape is an darwinian environment with specific characteristics,
    that determine the fitness of a life form, for that specific environment.")
    field(:theme, :string, default: "some theme")
    field(:image_url, :string, default: "https://picsum.photos/400/300")
    field(:nbr_of_countries, :integer, default: 1)
    field(:min_area, :integer)
    field(:min_people, :integer)
    field(:select_from, :string)
  end

  def changeset(scape, args)
      when is_map(args) do
    scape
    |> cast(args, @all_fields)
    |> validate_required(@required_fields)
  end

  def default(edge_id),
    do: europe(edge_id)

  def europe(edge_id),
    do: %ScapeInit{
      id: "europe",
      name: "Europe",
      edge_id: edge_id,
      nbr_of_countries: Swai.Limits.max_countries(),
      min_area: 30_000,
      min_people: 10_000_000,
      select_from: "Europe"
    }

  def asia(edge_id),
    do: %ScapeInit{
      id: "asia",
      name: "Asia",
      edge_id: edge_id,
      nbr_of_countries: Swai.Limits.max_countries(),
      min_area: 50_000,
      min_people: 40_000_000,
      select_from: "Asia"
    }

  def from_environment(edge_id) do
    %ScapeInit{
      id: System.get_env(@env_scape_id, "dairy-logs"),
      name: System.get_env(@env_scape_name, "DairyLogs"),
      description: System.get_env(@env_scape_description, "DairyLogs is a dairy farm Darwinian Environment.
      Drones are rewarded for breeding, producing milk and staying healthy."),
      theme: System.get_env(@env_scape_theme, "agriculture"),
      image_url: System.get_env(@env_scape_image_url, "https://picsum.photos/400/300"),
      edge_id: edge_id,
      nbr_of_countries: Swai.Limits.max_countries(),
      min_area: Swai.Limits.min_area(),
      min_people: Swai.Limits.min_people(),
      select_from: Swai.Limits.select_from()
    }
  end

  def from_config(edge_id) do
    %ScapeInit{
      id: Application.get_env(:Swai_edge, :scape_id),
      name: Application.get_env(:Swai_edge, :scape_name),
      edge_id: edge_id,
      nbr_of_countries: Application.get_env(:Swai_edge, :nbr_of_countries),
      min_area: Application.get_env(:Swai_edge, :min_area),
      min_people: Application.get_env(:Swai_edge, :min_people),
      select_from: Application.get_env(:Swai_edge, :select_from)
    }
  end

  def from_file(edge_id) do
    {:ok, file} = File.read("scape_init_params.json")
    {:ok, json} = Jason.decode(file)

    %ScapeInit{
      id: Map.get(json, "id"),
      name: Map.get(json, "name"),
      edge_id: edge_id,
      nbr_of_countries: Map.get(json, "nbr_of_countries"),
      min_area: Map.get(json, "min_area"),
      min_people: Map.get(json, "min_people"),
      select_from: Map.get(json, "select_from")
    }
  end

  def from_random(edge_id) do
    %ScapeInit{
      id: Scape.random_id(),
      name: MnemonicSlugs.generate_slug(2),
      edge_id: edge_id,
      nbr_of_countries: Swai.Limits.max_countries(),
      min_area: 30_000,
      min_people: 10_000_000,
      select_from: "Europe"
    }
  end

  def from_map(map) when is_map(map) do
    case(changeset(%ScapeInit{}, map)) do
      %{valid?: true} = changeset ->
        scape_init =
          changeset
          |> apply_changes()

        {:ok, scape_init}

      changeset ->
        {:error, changeset}
    end
  end
end
