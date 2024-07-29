defmodule Swai.WorkspaceTest do
  use Swai.DataCase

  alias Swai.Workspace

  describe "swarm_trainings" do
    alias Schema.SwarmTraining

    import Swai.WorkspaceFixtures

    @invalid_attrs %{status: nil, swarm_size: nil, nbr_of_generations: nil, drone_depth: nil, generation_epoch_in_minutes: nil, select_best_count: nil, cost_in_tokens: nil, tokens_used: nil, total_run_time_in_seconds: nil, budget_in_tokens: nil}

    test "list_swarm_trainings/0 returns all swarm_trainings" do
      swarm_training = swarm_training_fixture()
      assert Workspace.list_swarm_trainings() == [swarm_training]
    end

    test "get_swarm_training!/1 returns the swarm_training with given id" do
      swarm_training = swarm_training_fixture()
      assert Workspace.get_swarm_training!(swarm_training.id) == swarm_training
    end

    test "create_swarm_training/1 with valid data creates a swarm_training" do
      valid_attrs = %{status: 42, swarm_size: 42, nbr_of_generations: 42, drone_depth: 42, generation_epoch_in_minutes: 42, select_best_count: 42, cost_in_tokens: 42, tokens_used: 42, total_run_time_in_seconds: 42, budget_in_tokens: 42}

      assert {:ok, %SwarmTraining{} = swarm_training} = Workspace.create_swarm_training(valid_attrs)
      assert swarm_training.status == 42
      assert swarm_training.swarm_size == 42
      assert swarm_training.nbr_of_generations == 42
      assert swarm_training.drone_depth == 42
      assert swarm_training.generation_epoch_in_minutes == 42
      assert swarm_training.select_best_count == 42
      assert swarm_training.cost_in_tokens == 42
      assert swarm_training.tokens_used == 42
      assert swarm_training.total_run_time_in_seconds == 42
      assert swarm_training.budget_in_tokens == 42
    end

    test "create_swarm_training/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Workspace.create_swarm_training(@invalid_attrs)
    end

    test "update_swarm_training/2 with valid data updates the swarm_training" do
      swarm_training = swarm_training_fixture()
      update_attrs = %{status: 43, swarm_size: 43, nbr_of_generations: 43, drone_depth: 43, generation_epoch_in_minutes: 43, select_best_count: 43, cost_in_tokens: 43, tokens_used: 43, total_run_time_in_seconds: 43, budget_in_tokens: 43}

      assert {:ok, %SwarmTraining{} = swarm_training} = Workspace.update_swarm_training(swarm_training, update_attrs)
      assert swarm_training.status == 43
      assert swarm_training.swarm_size == 43
      assert swarm_training.nbr_of_generations == 43
      assert swarm_training.drone_depth == 43
      assert swarm_training.generation_epoch_in_minutes == 43
      assert swarm_training.select_best_count == 43
      assert swarm_training.cost_in_tokens == 43
      assert swarm_training.tokens_used == 43
      assert swarm_training.total_run_time_in_seconds == 43
      assert swarm_training.budget_in_tokens == 43
    end

    test "update_swarm_training/2 with invalid data returns error changeset" do
      swarm_training = swarm_training_fixture()
      assert {:error, %Ecto.Changeset{}} = Workspace.update_swarm_training(swarm_training, @invalid_attrs)
      assert swarm_training == Workspace.get_swarm_training!(swarm_training.id)
    end

    test "delete_swarm_training/1 deletes the swarm_training" do
      swarm_training = swarm_training_fixture()
      assert {:ok, %SwarmTraining{}} = Workspace.delete_swarm_training(swarm_training)
      assert_raise Ecto.NoResultsError, fn -> Workspace.get_swarm_training!(swarm_training.id) end
    end

    test "change_swarm_training/1 returns a swarm_training changeset" do
      swarm_training = swarm_training_fixture()
      assert %Ecto.Changeset{} = Workspace.change_swarm_training(swarm_training)
    end
  end
end
