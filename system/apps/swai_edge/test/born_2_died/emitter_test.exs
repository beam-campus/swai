defmodule Swai.Born2Died.HealthEmitterTest do
  use ExUnit.Case

  @moduledoc """
  These are the tests for Swai.Born2Died.HealthEmitter
 """

  require Logger
  alias Swai.Born2Died.HealthEmitter

  @edge_id "edge-1"

  setup_all do
    res = Edge.Client.start_link(@edge_id)
    Logger.info("Edge.Client.start_link/1: #{inspect(res)}")
    res
  end

  @tag :ignore_test
  test "that the Swai.Born2Died.HealthEmitter module exists" do
    assert is_list(Swai.Born2Died.HealthEmitter.module_info())
  end

  test "emit_born/2 emits the 'emit_born' fact" do
    # Arrange
    life_id = 123
    fact = %{name: "John", age: 30}

    # Act
    result = Emitter.emit_born(life_id, {:emit_born, fact})

    # Assert
    assert result == {:ok, {:emit_born, fact}}
  end

  test "emit_died/2 emits the 'emit_died' fact" do
    # Arrange
    life_id = 123
    fact = %{name: "John", age: 30}

    # Act
    result = Emitter.emit_died(life_id, {:emit_died, fact})

    # Assert
    assert result == {:ok, {:emit_died, fact}}
  end

  test "via/1 returns the correct tuple" do
    # Arrange
    life_id = 123

    # Act
    result = Emitter.via(life_id)

    # Assert
    assert result == {:emitter, "life-123"}
  end

  test "child_spec/1 returns the correct map" do
    # Arrange
    state = %{life: %{id: 123}}

    # Act
    result = Emitter.child_spec(state)

    # Assert
    assert result == %{
             id: {:emitter, "life-123"},
             start: {Swai.Born2Died.HealthEmitter, :start_link, [state]},
             type: :worker,
             restart: :transient
           }
  end

  test "start_link/1 returns the correct result" do
    # Arrange
    state = %{life: %{id: 123}}

    # Act
    result = Emitter.start_link(state)

    # Assert
    assert result == {:ok, {:emitter, "life-123"}}
  end
end
