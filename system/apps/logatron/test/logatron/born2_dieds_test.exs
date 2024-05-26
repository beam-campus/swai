defmodule Logatron.Born2DiedsTest do
  use Logatron.DataCase

  alias Logatron.Born2Dieds

  describe "born_2_dieds" do
    alias Logatron.Born2Dieds.Animal

    import Logatron.Born2DiedsFixtures

    @invalid_attrs %{id: nil, name: nil, status: nil, y: nil, x: nil, z: nil, edge_id: nil, scape_id: nil, region_id: nil, farm_id: nil, field_id: nil, life_id: nil, gender: nil, father_id: nil, mother_id: nil, birth_date: nil, age: nil, weight: nil, energy: nil, is_pregnant: nil, heath: nil, health: nil}

    test "list_born_2_dieds/0 returns all born_2_dieds" do
      animal = animal_fixture()
      assert Born2Dieds.list_born_2_dieds() == [animal]
    end

    test "get_animal!/1 returns the animal with given id" do
      animal = animal_fixture()
      assert Born2Dieds.get_animal!(animal.id) == animal
    end

    test "create_animal/1 with valid data creates a animal" do
      valid_attrs = %{id: "some id", name: "some name", status: "some status", y: 42, x: 42, z: 42, edge_id: "some edge_id", scape_id: "some scape_id", region_id: "some region_id", farm_id: "some farm_id", field_id: "some field_id", life_id: "some life_id", gender: "some gender", father_id: "some father_id", mother_id: "some mother_id", birth_date: ~D[2024-04-07], age: 42, weight: 42, energy: 42, is_pregnant: true, heath: 42, health: 42}

      assert {:ok, %Animal{} = animal} = Born2Dieds.create_animal(valid_attrs)
      assert animal.id == "some id"
      assert animal.name == "some name"
      assert animal.status == "some status"
      assert animal.y == 42
      assert animal.x == 42
      assert animal.z == 42
      assert animal.edge_id == "some edge_id"
      assert animal.scape_id == "some scape_id"
      assert animal.region_id == "some region_id"
      assert animal.farm_id == "some farm_id"
      assert animal.field_id == "some field_id"
      assert animal.life_id == "some life_id"
      assert animal.gender == "some gender"
      assert animal.father_id == "some father_id"
      assert animal.mother_id == "some mother_id"
      assert animal.birth_date == ~D[2024-04-07]
      assert animal.age == 42
      assert animal.weight == 42
      assert animal.energy == 42
      assert animal.is_pregnant == true
      assert animal.heath == 42
      assert animal.health == 42
    end

    test "create_animal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Born2Dieds.create_animal(@invalid_attrs)
    end

    test "update_animal/2 with valid data updates the animal" do
      animal = animal_fixture()
      update_attrs = %{id: "some updated id", name: "some updated name", status: "some updated status", y: 43, x: 43, z: 43, edge_id: "some updated edge_id", scape_id: "some updated scape_id", region_id: "some updated region_id", farm_id: "some updated farm_id", field_id: "some updated field_id", life_id: "some updated life_id", gender: "some updated gender", father_id: "some updated father_id", mother_id: "some updated mother_id", birth_date: ~D[2024-04-08], age: 43, weight: 43, energy: 43, is_pregnant: false, heath: 43, health: 43}

      assert {:ok, %Animal{} = animal} = Born2Dieds.update_animal(animal, update_attrs)
      assert animal.id == "some updated id"
      assert animal.name == "some updated name"
      assert animal.status == "some updated status"
      assert animal.y == 43
      assert animal.x == 43
      assert animal.z == 43
      assert animal.edge_id == "some updated edge_id"
      assert animal.scape_id == "some updated scape_id"
      assert animal.region_id == "some updated region_id"
      assert animal.farm_id == "some updated farm_id"
      assert animal.field_id == "some updated field_id"
      assert animal.life_id == "some updated life_id"
      assert animal.gender == "some updated gender"
      assert animal.father_id == "some updated father_id"
      assert animal.mother_id == "some updated mother_id"
      assert animal.birth_date == ~D[2024-04-08]
      assert animal.age == 43
      assert animal.weight == 43
      assert animal.energy == 43
      assert animal.is_pregnant == false
      assert animal.heath == 43
      assert animal.health == 43
    end

    test "update_animal/2 with invalid data returns error changeset" do
      animal = animal_fixture()
      assert {:error, %Ecto.Changeset{}} = Born2Dieds.update_animal(animal, @invalid_attrs)
      assert animal == Born2Dieds.get_animal!(animal.id)
    end

    test "delete_animal/1 deletes the animal" do
      animal = animal_fixture()
      assert {:ok, %Animal{}} = Born2Dieds.delete_animal(animal)
      assert_raise Ecto.NoResultsError, fn -> Born2Dieds.get_animal!(animal.id) end
    end

    test "change_animal/1 returns a animal changeset" do
      animal = animal_fixture()
      assert %Ecto.Changeset{} = Born2Dieds.change_animal(animal)
    end
  end
end
