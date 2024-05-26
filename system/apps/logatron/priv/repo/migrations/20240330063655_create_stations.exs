defmodule Logatron.Repo.Migrations.CreateStations do
  use Ecto.Migration

  def change do
    create table(:stations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :add, :string
      add :name, :string
      add :description, :text
      add :user_id, :string
      add :location_id, :string
      add :gateway, :string
      add :nature, :string

      timestamps()
    end
  end
end
