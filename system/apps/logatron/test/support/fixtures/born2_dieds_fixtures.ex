defmodule Logatron.Born2DiedsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Logatron.Born2Dieds` context.
  """

  @doc """
  Generate a animal.
  """
  def animal_fixture(attrs \\ %{}) do
    {:ok, animal} =
      attrs
      |> Enum.into(%{
        age: 42,
        birth_date: ~D[2024-04-07],
        edge_id: "some edge_id",
        energy: 42,
        farm_id: "some farm_id",
        father_id: "some father_id",
        field_id: "some field_id",
        gender: "some gender",
        health: 42,
        heath: 42,
        id: "some id",
        is_pregnant: true,
        life_id: "some life_id",
        mother_id: "some mother_id",
        name: "some name",
        region_id: "some region_id",
        scape_id: "some scape_id",
        status: "some status",
        weight: 42,
        x: 42,
        y: 42,
        z: 42
      })
      |> Logatron.Born2Dieds.create_animal()

    animal
  end
end
