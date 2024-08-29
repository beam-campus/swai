defmodule EnvVars do
  @moduledoc """
  The EnvVars module is used to define environment variables
  """

  def swai_edge_api_key,
    do: "SWAI_EDGE_API_KEY"

  def swai_edge_biotope_id,
    do: "SWAI_EDGE_BIOTOPE_ID"

  def swai_edge_algorithm_acronym,
    do: "SWAI_EDGE_ALGORITHM_ACRONYM"

  def swai_edge_lat,
    do: "SWAI_EDGE_LAT"

  def swai_edge_lon,
    do: "SWAI_EDGE_LON"

  def swai_edge_is_container,
    do: "SWAI_EDGE_IS_CONTAINER"

  def swai_edge_is_root,
    do: "SWAI_EDGE_IS_ROOT"

  def swai_edge_country,
    do: "SWAI_EDGE_COUNTRY"

  def swai_edge_country_code,
    do: "SWAI_EDGE_COUNTRY_CODE"


  def swai_edge_scape_select_from,
    do: "SWAI_CONTINENTS"

  # def swai_edge_max_countries,
  #   do: "SWAI_MAX_COUNTRIES_PER_CONTINENT"

  def swai_edge_scape_min_area,
    do: "SWAI_MIN_COUNTRY_AREA_KM2"

  def swai_edge_scape_min_people,
    do: "SWAI_MIN_COUNTRY_POPULATION"

  def swai_edge_max_farms,
    do: "SWAI_MAX_FARMS_PER_COUNTRY"

  def swai_edge_max_animals,
    do: "SWAI_MAX_ANIMALS_PER_FARM"

  def swai_init_animals_per_farm,
    do: "SWAI_INIT_ANIMALS_PER_FARM"

  def swai_edge_scape_nbr_of_countries,
    do: "SWAI_MAX_COUNTRIES"

  def swai_edge_scape_description,
    do: "SWAI_SCAPE_DESCRIPTION"

  def swai_edge_scape_theme,
    do: "SWAI_SCAPE_THEME"

  def swai_edge_scape_image_url,
    do: "SWAI_SCAPE_IMAGE_URL"

  def get_env_var_as_integer(var_name, default \\ 0) do
    case System.get_env(var_name) do
      nil ->
        default

      value ->
        case Integer.parse(value) do
          :error -> default
          {int_value, _} -> int_value
        end
    end
  end

  def get_env_var_as_float(var_name, default \\ 0.0) do
    case System.get_env(var_name) do
      nil ->
        default

      value ->
        case Float.parse(value) do
          :error -> default
          {float_value, _} -> float_value
        end
    end
  end

  def get_env_var_as_boolean(var_name, default \\ false) do
    case System.get_env(var_name) do
      nil ->
        default

      value ->
        case value do
          "1" -> true
          1 -> true
          "0" -> false
          0 -> false
          "true" -> true
          true -> true
          "false" -> false
          false -> false
          _ -> default
        end
    end
  end
end
