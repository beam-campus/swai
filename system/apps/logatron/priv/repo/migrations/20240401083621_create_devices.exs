defmodule Logatron.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :add, :string
      add :name, :string
      add :description, :text
      add :user_id, :string
      add :brand, :string
      add :model, :string
      add :arcitecture, :string
      add :cpu, :string
      add :clock_mhz, :string
      add :cores, :integer
      add :ram_gb, :integer
      add :storage_gb, :integer
      add :network, :string
      add :mac_address, :string
      add :root_os, :string
      add :os_version, :string
      add :runtime, :string
      add :runtime_version, :string

      timestamps()
    end
  end
end
