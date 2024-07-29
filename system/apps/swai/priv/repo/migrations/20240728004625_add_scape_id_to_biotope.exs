defmodule Swai.Repo.Migrations.AddScapeIdToBiotope do
  use Ecto.Migration

  def change do
    alter table("biotopes") do
      add(:scape_id, :string)
    end
  end
end
