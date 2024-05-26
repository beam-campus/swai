defmodule Logatron.Born2Died.AggregateTest do
  @moduledoc """
  Logatron.Born2Died.AggregateTest is the aggregate test for the Born2Died domain.
  """
  use ExUnit.Case, async: true

  test "that we can start the Aggregate Actor" do
    agg_state = %{
      state:
        Born2Died.State.random(
          "edge_1",
          Schema.Vector.new(100, 100, 0),
          Schema.Life.random()
        ),
      events: []
    }

    case Logatron.Born2Died.Aggregate.start_link(agg_state) do
      {:ok, pid} ->
        assert {:ok, pid} == {:ok, pid}

      {error, {:already_started, pid}} ->
        assert {:ok, pid} == {:ok, pid}

      reply ->
        assert false
    end
  end
end
