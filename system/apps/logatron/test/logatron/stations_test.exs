defmodule Logatron.StationsTest do
  use Logatron.DataCase

  alias Logatron.Stations

  describe "stations" do
    alias Logatron.Stations.Station

    import Logatron.StationsFixtures

    @invalid_attrs %{name: nil, add: nil, description: nil, user_id: nil, location_id: nil, gateway: nil, nature: nil}

    test "list_stations/0 returns all stations" do
      station = station_fixture()
      assert Stations.list_stations() == [station]
    end

    test "get_station!/1 returns the station with given id" do
      station = station_fixture()
      assert Stations.get_station!(station.id) == station
    end

    test "create_station/1 with valid data creates a station" do
      valid_attrs = %{name: "some name", add: "some add", description: "some description", user_id: "some user_id", location_id: "some location_id", gateway: "some gateway", nature: "some nature"}

      assert {:ok, %Station{} = station} = Stations.create_station(valid_attrs)
      assert station.name == "some name"
      assert station.add == "some add"
      assert station.description == "some description"
      assert station.user_id == "some user_id"
      assert station.location_id == "some location_id"
      assert station.gateway == "some gateway"
      assert station.nature == "some nature"
    end

    test "create_station/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stations.create_station(@invalid_attrs)
    end

    test "update_station/2 with valid data updates the station" do
      station = station_fixture()
      update_attrs = %{name: "some updated name", add: "some updated add", description: "some updated description", user_id: "some updated user_id", location_id: "some updated location_id", gateway: "some updated gateway", nature: "some updated nature"}

      assert {:ok, %Station{} = station} = Stations.update_station(station, update_attrs)
      assert station.name == "some updated name"
      assert station.add == "some updated add"
      assert station.description == "some updated description"
      assert station.user_id == "some updated user_id"
      assert station.location_id == "some updated location_id"
      assert station.gateway == "some updated gateway"
      assert station.nature == "some updated nature"
    end

    test "update_station/2 with invalid data returns error changeset" do
      station = station_fixture()
      assert {:error, %Ecto.Changeset{}} = Stations.update_station(station, @invalid_attrs)
      assert station == Stations.get_station!(station.id)
    end

    test "delete_station/1 deletes the station" do
      station = station_fixture()
      assert {:ok, %Station{}} = Stations.delete_station(station)
      assert_raise Ecto.NoResultsError, fn -> Stations.get_station!(station.id) end
    end

    test "change_station/1 returns a station changeset" do
      station = station_fixture()
      assert %Ecto.Changeset{} = Stations.change_station(station)
    end
  end
end
