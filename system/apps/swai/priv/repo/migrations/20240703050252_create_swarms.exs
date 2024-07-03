defmodule Swai.Repo.Migrations.CreateSwarms do
  use Ecto.Migration

  def change do
    create table(:swarms, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:description, :string)
      add(:user_id, :string)
      add(:status, :integer)
      add(:biotope_id, :string)
      add(:edge_id, :string)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
