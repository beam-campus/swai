defmodule Scape.SystemTest do
  @moduledoc """
  This module tests the Scape.System module.
  """
  use ExUnit.Case

  require Logger

  @test_scape_params %{
    id: "farm_scape",
    nbr_of_regions: 5,
    min_area: 30_000,
    min_people: 10_000_000
  }

  @tag :test_scape_system
  doctest Scape.System

  describe "\n[~> Setup the Scape.System test environment <~]\n" do
    setup %{} do
      case res = Logatron.Countries.Cache.start_link([]) do
        {:ok, cache} ->
          {:ok, cache}

        {:error, {:already_started, _}} ->
          Logger.info("Cache has already started")
      end
    end

    @tag :test_scape_system
    test "\n[== Test that we can start the Scape.System ==]" do
      res = Scape.System.start_link(@test_scape_params)

      case res do
        {:ok, _} ->
          assert true

        {:error, {:already_started, _}} ->
          assert true
      end

      Logger.debug("Scape.System.start_link/1 returned => #{inspect(res)}")
    end

    @tag :test_scape_system
    test "that the Scape.System module exists" do
      assert is_list(Scape.System.module_info())
    end

    @tag :test_scape_system
    test "that we can start the Scape.System for a particular scape" do
      res =
        Scape.System.start_link(@test_scape_params)

      inspect(res)
    end
  end
end
