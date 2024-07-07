defmodule Swai.Repo.Migrations.AddAdditionalUserFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:alias, :string)
      add(:bio, :text)
      add(:image_url, :string)
      add(:budget, :integer, default: 100)
      add(:wants_notifications?, :boolean, default: true)
      add(:has_accepted_terms?, :boolean, default: true)
    end
  end
end
