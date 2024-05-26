defmodule Logatron.Limits do
  require Config

  @moduledoc """
  Agrex.Limits is the module that contains the limits for the Life Subsystem
  """

  @defaults [
    ticks_per_year: 20,
    min_area: 30_000,
    min_people: 10_000_000,
    min_lives: 3,
    min_age: 1,
    max_age: 25,
    max_countries: 3,
    max_farms: 5,
    max_lives: 20,
    min_weight: 50,
    max_weight: 750,
    max_robots: 3,
    min_robots: 2,
    select_from: "Europe",
    init_nbr_of_lives: 5
  ]

  def min_area,
    do:
      System.get_env(EnvVars.logatron_edge_scape_min_area()) ||
        @defaults[:min_area]

  def min_people,
    do:
      EnvVars.get_env_var_as_integer(
        EnvVars.logatron_edge_scape_min_people(),
        @defaults[:min_people]
      )

  def init_nbr_of_lives,
    do:
    EnvVars.get_env_var_as_integer(
      EnvVars.logatron_edge_max_animals(),
      EnvVars.get_env_var_as_integer(
        EnvVars.logatron_init_animals_per_farm(),
        @defaults[:max_lives]
      )

    )




  def min_lives,
    do: @defaults[:min_lives]

  def min_age, do: @defaults[:min_age]
  def max_age, do: @defaults[:max_age]

  def max_countries,
    do:
      EnvVars.get_env_var_as_integer(
        EnvVars.logatron_edge_scape_nbr_of_countries(),
        @defaults[:max_countries]
      )

  def max_farms,
    do:
      EnvVars.get_env_var_as_integer(
        EnvVars.logatron_edge_max_farms(),
        @defaults[:max_farms]
      )

  def max_lives,
    do:
      EnvVars.get_env_var_as_integer(
        EnvVars.logatron_edge_max_animals(),
        @defaults[:max_lives]
      )

  def min_weight, do: @defaults[:min_weight]
  def max_weight, do: @defaults[:max_weight]
  def max_robots, do: @defaults[:max_robots]
  def min_robots, do: @defaults[:min_robots]
  def ticks_per_year, do: @defaults[:ticks_per_year]

  def select_from,
    do:
      System.get_env(EnvVars.logatron_edge_scape_select_from()) ||
        @defaults[:select_from]

  def random_age do
    ma = :rand.uniform(min_age())
    res = abs(:rand.uniform(max_age()) - ma)
    if res == 0, do: random_age()
    if res < ma, do: random_age()
    res
  end

  def random_weight do
    res = abs(:rand.uniform(max_weight()) - :rand.uniform(min_weight()))
    mw = min_weight()

    if res == 0, do: random_weight()
    if res < mw, do: random_weight()
    res
  end

  def max_nbr_lives() do
    ml = :rand.uniform(min_lives())
    res = abs(:rand.uniform(max_lives()) - ml)

    case res do
      0 -> ml
      _ -> res
    end
  end

  def random_100 do
    :rand.uniform(100)
  end

  def random_pos(max_x, max_y, max_z \\ 1)
      when is_integer(max_x) and
             is_integer(max_y) and
             is_integer(max_z) and
             max_x > 0 and
             max_y > 0 do
    %{
      x: :rand.uniform(max_x),
      y: :rand.uniform(max_y),
      z: :rand.uniform(max_z)
    }
  end
end
