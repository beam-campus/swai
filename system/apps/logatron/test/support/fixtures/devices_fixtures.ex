defmodule Logatron.DevicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Logatron.Devices` context.
  """

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    {:ok, device} =
      attrs
      |> Enum.into(%{
        add: "some add",
        arcitecture: "some arcitecture",
        brand: "some brand",
        clock_mhz: "some clock_mhz",
        cores: 42,
        cpu: "some cpu",
        description: "some description",
        mac_address: "some mac_address",
        model: "some model",
        name: "some name",
        network: "some network",
        os_version: "some os_version",
        ram_gb: 42,
        root_os: "some root_os",
        runtime: "some runtime",
        runtime_version: "some runtime_version",
        storage_gb: 42,
        user_id: "some user_id"
      })
      |> Logatron.Devices.create_device()

    device
  end
end
