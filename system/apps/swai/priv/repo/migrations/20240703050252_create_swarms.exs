defmodule Swai.Repo.Migrations.CreateSwarms do
  use Ecto.Migration

  def change do
    create table(:swarms, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:description, :text)
      add(:user_id, :string)
      add(:status, :integer)
      add(:biotope_id, :string)
      add(:edge_id, :string)
      add(:budget, :integer, default: 1_000)
      add(:ranking, :integer, default: 10_000)
      add(:quality, :integer, default: 10)
      add(:generation, :integer, default: 1)
      add(:size, :integer, default: 10)


      timestamps(type: :utc_datetime_usec)
    end
  end
end
