defmodule Swai.Repo.Migrations.ExpandSwarms do
  use Ecto.Migration

  def change do
    alter table(:swarms) do
      add(:budget, :integer, default: 1_000)
      add(:ranking, :integer, default: 10_000)
      add(:quality, :integer, default: 10)
      add(:generation, :integer, default: 1)
      add(:size, :integer, default: 10)
      modify(:description, :text)
    end
  end
end
