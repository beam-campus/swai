defmodule Swai.Repo.Migrations.CreateBiotopes do
  use Ecto.Migration

  def change do
    create table(:biotopes, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:description, :string)
      add(:image_url, :string)
      add(:theme, :string)
      add(:tags, :string)

      timestamps(type: :utc_datetime_usec)
    end
  end
end
