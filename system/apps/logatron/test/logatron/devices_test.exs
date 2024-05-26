defmodule Logatron.DevicesTest do
  use Logatron.DataCase

  alias Logatron.Devices

  describe "devices" do
    alias Logatron.Devices.Device

    import Logatron.DevicesFixtures

    @invalid_attrs %{cpu: nil, name: nil, os_version: nil, runtime: nil, add: nil, description: nil, user_id: nil, brand: nil, model: nil, arcitecture: nil, clock_mhz: nil, cores: nil, ram_gb: nil, storage_gb: nil, network: nil, mac_address: nil, root_os: nil, runtime_version: nil}

    test "list_devices/0 returns all devices" do
      device = device_fixture()
      assert Devices.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = device_fixture()
      assert Devices.get_device!(device.id) == device
    end

    test "create_device/1 with valid data creates a device" do
      valid_attrs = %{cpu: "some cpu", name: "some name", os_version: "some os_version", runtime: "some runtime", add: "some add", description: "some description", user_id: "some user_id", brand: "some brand", model: "some model", arcitecture: "some arcitecture", clock_mhz: "some clock_mhz", cores: 42, ram_gb: 42, storage_gb: 42, network: "some network", mac_address: "some mac_address", root_os: "some root_os", runtime_version: "some runtime_version"}

      assert {:ok, %Device{} = device} = Devices.create_device(valid_attrs)
      assert device.cpu == "some cpu"
      assert device.name == "some name"
      assert device.os_version == "some os_version"
      assert device.runtime == "some runtime"
      assert device.add == "some add"
      assert device.description == "some description"
      assert device.user_id == "some user_id"
      assert device.brand == "some brand"
      assert device.model == "some model"
      assert device.arcitecture == "some arcitecture"
      assert device.clock_mhz == "some clock_mhz"
      assert device.cores == 42
      assert device.ram_gb == 42
      assert device.storage_gb == 42
      assert device.network == "some network"
      assert device.mac_address == "some mac_address"
      assert device.root_os == "some root_os"
      assert device.runtime_version == "some runtime_version"
    end

    test "create_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Devices.create_device(@invalid_attrs)
    end

    test "update_device/2 with valid data updates the device" do
      device = device_fixture()
      update_attrs = %{cpu: "some updated cpu", name: "some updated name", os_version: "some updated os_version", runtime: "some updated runtime", add: "some updated add", description: "some updated description", user_id: "some updated user_id", brand: "some updated brand", model: "some updated model", arcitecture: "some updated arcitecture", clock_mhz: "some updated clock_mhz", cores: 43, ram_gb: 43, storage_gb: 43, network: "some updated network", mac_address: "some updated mac_address", root_os: "some updated root_os", runtime_version: "some updated runtime_version"}

      assert {:ok, %Device{} = device} = Devices.update_device(device, update_attrs)
      assert device.cpu == "some updated cpu"
      assert device.name == "some updated name"
      assert device.os_version == "some updated os_version"
      assert device.runtime == "some updated runtime"
      assert device.add == "some updated add"
      assert device.description == "some updated description"
      assert device.user_id == "some updated user_id"
      assert device.brand == "some updated brand"
      assert device.model == "some updated model"
      assert device.arcitecture == "some updated arcitecture"
      assert device.clock_mhz == "some updated clock_mhz"
      assert device.cores == 43
      assert device.ram_gb == 43
      assert device.storage_gb == 43
      assert device.network == "some updated network"
      assert device.mac_address == "some updated mac_address"
      assert device.root_os == "some updated root_os"
      assert device.runtime_version == "some updated runtime_version"
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = device_fixture()
      assert {:error, %Ecto.Changeset{}} = Devices.update_device(device, @invalid_attrs)
      assert device == Devices.get_device!(device.id)
    end

    test "delete_device/1 deletes the device" do
      device = device_fixture()
      assert {:ok, %Device{}} = Devices.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_device!(device.id) end
    end

    test "change_device/1 returns a device changeset" do
      device = device_fixture()
      assert %Ecto.Changeset{} = Devices.change_device(device)
    end
  end
end
