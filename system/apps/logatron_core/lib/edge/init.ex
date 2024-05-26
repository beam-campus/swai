defmodule Edge.Init do
  use Ecto.Schema

  @moduledoc """
  Edge.Init is the struct that identifies the state of a Region.
  """
  alias Edge.Init, as: EdgeInit
  alias AppUtils

  import Ecto.Changeset

  @all_fields [
    :id,
    :scape_id,
    :api_key,
    :is_container,
    :ip_address,
    :continent,
    :continent_code,
    :country,
    :country_code,
    :region,
    :region_name,
    :city,
    :district,
    :zip,
    :lat,
    :lon,
    :timezone,
    :offset,
    :currency,
    :isp,
    :org,
    :as,
    :asname,
    :reverse,
    :mobile,
    :proxy,
    :hosting,
    :connected_since
  ]

  @required_fields [
    :id,
    :scape_id,
    :api_key,
    :is_container,
    :connected_since
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:scape_id, :string)
    field(:api_key, :string)
    field(:is_container, :boolean, default: false)
    field(:ip_address, :string)
    field(:continent, :string)
    field(:continent_code, :string)
    field(:country, :string)
    field(:country_code, :string)
    field(:region, :string)
    field(:region_name, :string)
    field(:city, :string)
    field(:district, :string)
    field(:zip, :string)
    field(:lat, :float)
    field(:lon, :float)
    field(:timezone, :string)
    field(:offset, :integer)
    field(:currency, :string)
    field(:isp, :string)
    field(:org, :string)
    field(:as, :string)
    field(:asname, :string)
    field(:reverse, :string)
    field(:mobile, :boolean)
    field(:proxy, :boolean)
    field(:hosting, :boolean)
    field(:connected_since, :utc_datetime)
  end

  def changeset(edge, args)
      when is_map(args),
      do:
        edge
        |> cast(args, @all_fields)
        |> validate_required(@required_fields)

  def from_map(map) when is_map(map) do
    case(changeset(%EdgeInit{}, map)) do
      %{valid?: true} = changeset ->
        edge_init =
          changeset
          |> Ecto.Changeset.apply_changes()

        {:ok, edge_init}

      changeset ->
        {:error, changeset}
    end
  end

  def default,
    do: %EdgeInit{
      id: Logatron.Schema.Edge.random_id(),
      api_key: "europe_",
      is_container: AppUtils.running_in_container?()
    }

  def from_environment() do
    {:ok, chost} = :inet.gethostname()
    edge_id = "#{to_string(chost)}-" <> Logatron.Schema.Edge.random_id()

    api_key =
      case System.get_env("LOGATRON_EDGE_API_KEY") do
        nil -> "no-api-key"
        key -> key
      end

    scape_id =
      case System.get_env("LOGATRON_SCAPE_ID") do
        nil -> "no-scape-id"
        id -> id
      end

    %EdgeInit{
      id: edge_id,
      api_key: api_key,
      scape_id: scape_id,
      is_container: AppUtils.running_in_container?(),
      ip_address: "unknown",
      continent: "unknown",
      continent_code: "unknown",
      country: "unknown",
      country_code: "unknown",
      region: "unknown",
      region_name: "unknown",
      city: "unknown",
      zip: "unknown",
      lat: 0.0,
      lon: 0.0,
      timezone: "unknown",
      offset: 0,
      currency: "unknown",
      isp: "unknown",
      org: "unknown",
      as: "unknown",
      asname: "unknown",
      reverse: "unknown",
      mobile: false,
      proxy: false,
      hosting: false,
      connected_since: DateTime.utc_now()
    }
  end

  def from_environment(ip_info) when is_map(ip_info) do
    {:ok, chost} = :inet.gethostname()
    edge_id = "#{to_string(chost)}-" <> Logatron.Schema.Edge.random_id()

    api_key = System.get_env(EnvVars.logatron_edge_api_key(), "no-api-key")
    scape_id = System.get_env(EnvVars.logatron_edge_scape_id(), "dairy-logs")

    %EdgeInit{
      id: edge_id,
      scape_id: scape_id,
      api_key: api_key,
      is_container: AppUtils.running_in_container?(),
      ip_address: ip_info["query"],
      continent: ip_info["continent"],
      continent_code: ip_info["continentCode"],
      country: ip_info["country"],
      country_code: ip_info["countryCode"],
      region: ip_info["region"],
      region_name: ip_info["regionName"],
      city: ip_info["city"],
      zip: ip_info["zip"],
      lat: ip_info["lat"],
      lon: ip_info["lon"],
      timezone: ip_info["timezone"],
      offset: ip_info["offset"],
      currency: ip_info["currency"],
      isp: ip_info["isp"],
      org: ip_info["org"],
      as: ip_info["as"],
      asname: ip_info["asname"],
      reverse: ip_info["reverse"],
      mobile: ip_info["mobile"],
      proxy: ip_info["proxy"],
      hosting: ip_info["hosting"],
      connected_since: DateTime.utc_now()
    }
  end

  def enriched() do
    {:ok, ip_info} = Apis.IpInfoCache.refresh()

    from_environment(ip_info)
  end
end
