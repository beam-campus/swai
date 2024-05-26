defmodule Logatron.RobotWorkerTest do
  use ExUnit.Case

  alias Logatron.Robot.Worker
  alias Schema.Robot

  @tag :ignore_test
  test "that the module exists" do
    assert is_list(RobotWorker.module_info())
  end

  @tag :ignore_test
  test "that we can start a RobotWorker" do
    {:ok, robot} = Robot.new(%{ name: "Robby" })
    assert robot != nil
    {:ok, pid} = Worker.start_link(robot)
    assert Process.alive?(pid)
  end




end
