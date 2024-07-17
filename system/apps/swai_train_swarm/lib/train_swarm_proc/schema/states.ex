defmodule TrainSwarmProc.Schema.States do

  def unknown, do: 0
  def initialized, do: 1
  def configured, do: 2
  def running, do: 4
  def paused, do: 8
  def completed, do: 16

end
