defmodule Swai.Devices.Device do
  use Ecto.Schema

  @moduledoc """
  Device schema
  """

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "devices" do
    field :cpu, :string
    field :name, :string
    field :os_version, :string
    field :runtime, :string
    field :add, :string
    field :description, :string
    field :user_id, :string
    field :brand, :string
    field :model, :string
    field :architecture, :string
    field :clock_mhz, :string
    field :cores, :integer
    field :ram_gb, :integer
    field :storage_gb, :integer
    field :network, :string
    field :mac_address, :string
    field :root_os, :string
    field :runtime_version, :string

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:add, :name, :description, :user_id, :brand, :model, :architecture, :cpu, :clock_mhz, :cores, :ram_gb, :storage_gb, :network, :mac_address, :root_os, :os_version, :runtime, :runtime_version])
    |> validate_required([:add, :name, :description, :user_id, :brand, :model, :architecture, :cpu, :clock_mhz, :cores, :ram_gb, :storage_gb, :network, :mac_address, :root_os, :os_version, :runtime, :runtime_version])
  end
end
