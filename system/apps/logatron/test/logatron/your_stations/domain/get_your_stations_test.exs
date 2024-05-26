defmodule Logatron.YourStations.Domain.GetYourStationsTest do
  use ExUnit.Case, async: true

  @moduledoc """
  Tests for GetYourStations domain module.
  """
  alias Logatron.YourStations.Domain.GetYourStations

  require Logger


  @tag :your_stations_domain_tests
  test "[that execute/1 returns a list of stations for a given user]" do
    # GIVEN
    user_email = "rl@DisComCo.pl"
    # WHEN
    result = GetYourStations.execute(user_email)

    Logger.info("Result: #{inspect(result)}")

    # THEN
    assert length(result) == 2
  end
end
