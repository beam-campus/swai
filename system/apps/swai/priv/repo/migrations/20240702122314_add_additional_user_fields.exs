defmodule Swai.Repo.Migrations.AddAdditionalUserFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:user_name, :string)
      add(:bio, :text)
      add(:image_url, :string)
    end
  end
end
