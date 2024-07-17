defmodule SwaiWeb.SwarmTrainingLiveTest do
  use SwaiWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swai.WorkspaceFixtures

  @create_attrs %{status: 42, swarm_size: 42, nbr_of_generations: 42, drone_depth: 42, generation_epoch_in_minutes: 42, select_best_count: 42, cost_in_tokens: 42, tokens_used: 42, total_run_time_in_seconds: 42, budget_in_tokens: 42}
  @update_attrs %{status: 43, swarm_size: 43, nbr_of_generations: 43, drone_depth: 43, generation_epoch_in_minutes: 43, select_best_count: 43, cost_in_tokens: 43, tokens_used: 43, total_run_time_in_seconds: 43, budget_in_tokens: 43}
  @invalid_attrs %{status: nil, swarm_size: nil, nbr_of_generations: nil, drone_depth: nil, generation_epoch_in_minutes: nil, select_best_count: nil, cost_in_tokens: nil, tokens_used: nil, total_run_time_in_seconds: nil, budget_in_tokens: nil}

  defp create_swarm_training(_) do
    swarm_training = swarm_training_fixture()
    %{swarm_training: swarm_training}
  end

  describe "Index" do
    setup [:create_swarm_training]

    test "lists all swarm_trainings", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/swarm_trainings")

      assert html =~ "Listing Swarm trainings"
    end

    test "saves new swarm_training", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/swarm_trainings")

      assert index_live |> element("a", "New Swarm training") |> render_click() =~
               "New Swarm training"

      assert_patch(index_live, ~p"/swarm_trainings/new")

      assert index_live
             |> form("#swarm_training-form", swarm_training: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#swarm_training-form", swarm_training: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/swarm_trainings")

      html = render(index_live)
      assert html =~ "Swarm training created successfully"
    end

    test "updates swarm_training in listing", %{conn: conn, swarm_training: swarm_training} do
      {:ok, index_live, _html} = live(conn, ~p"/swarm_trainings")

      assert index_live |> element("#swarm_trainings-#{swarm_training.id} a", "Edit") |> render_click() =~
               "Edit Swarm training"

      assert_patch(index_live, ~p"/swarm_trainings/#{swarm_training}/edit")

      assert index_live
             |> form("#swarm_training-form", swarm_training: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#swarm_training-form", swarm_training: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/swarm_trainings")

      html = render(index_live)
      assert html =~ "Swarm training updated successfully"
    end

    test "deletes swarm_training in listing", %{conn: conn, swarm_training: swarm_training} do
      {:ok, index_live, _html} = live(conn, ~p"/swarm_trainings")

      assert index_live |> element("#swarm_trainings-#{swarm_training.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#swarm_trainings-#{swarm_training.id}")
    end
  end

  describe "Show" do
    setup [:create_swarm_training]

    test "displays swarm_training", %{conn: conn, swarm_training: swarm_training} do
      {:ok, _show_live, html} = live(conn, ~p"/swarm_trainings/#{swarm_training}")

      assert html =~ "Show Swarm training"
    end

    test "updates swarm_training within modal", %{conn: conn, swarm_training: swarm_training} do
      {:ok, show_live, _html} = live(conn, ~p"/swarm_trainings/#{swarm_training}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Swarm training"

      assert_patch(show_live, ~p"/swarm_trainings/#{swarm_training}/show/edit")

      assert show_live
             |> form("#swarm_training-form", swarm_training: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#swarm_training-form", swarm_training: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/swarm_trainings/#{swarm_training}")

      html = render(show_live)
      assert html =~ "Swarm training updated successfully"
    end
  end
end
