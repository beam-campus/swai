defmodule Region.SystemTest do
  use ExUnit.Case


  @test_scape

  @tag :ignore_test
  doctest Region.System

  alias Region.System

  @tag :ignore_test
  test "that the Region.System module exists" do
    assert is_list(Region.System.module_info())
  end


  @tag :ignore_test
  test "that we can start a Region.System" do
    scape = @test_scape
    res =  Region.System.start_link(nil,nil)
    case res do
      {:ok, pid} ->
        assert pid != nil
        assert Process.alive?(pid)
      {:error, {:already_started, pid}} ->
        assert pid != nil
        assert Process.alive?(pid)
    end
  end


end
