defmodule Scape.Status do
  @moduledoc """
  Status is an enum that represents the status of a Scape.
  """
  def unknown(), do: 0
  def initializing(), do: 1
  def initialized(), do: 2
  def running(), do: 4
  def stopping(), do: 8
  def stopped(), do: 16
end
