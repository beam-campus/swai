defmodule MngFarm.SystemTest do
  @moduledoc """
  This module tests the Swai.Farm.System module.
  """
  use ExUnit.Case

  alias MngFarm.System

  @tag :ignore_test
  doctest MngFarm.System

  @tag :ignore_test
  test "that the MngFarm.System module exists" do
    assert is_list(MngFarm.System.module_info())
  end

end
