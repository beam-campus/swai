defmodule Logatron.StationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Logatron.Stations` context.
  """

  @doc """
  Generate a station.
  """
  def station_fixture(attrs \\ %{}) do
    {:ok, station} =
      attrs
      |> Enum.into(%{
        add: "some add",
        description: "some description",
        gateway: "some gateway",
        location_id: "some location_id",
        name: "some name",
        nature: "some nature",
        user_id: "some user_id"
      })
      |> Logatron.Stations.create_station()

    station
  end
end
