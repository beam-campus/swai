defmodule Edge.EmitterTest do
  use ExUnit.Case

  @moduledoc """
  Tests for the Edge.Emitter module.
  """

  @tag :ignore_test
  doctest Edge.Emitter

  @tag :ignore_test
  test "that the Edge.Emitter module exists" do
    assert is_list(Edge.Emitter.module_info())
  end
end
