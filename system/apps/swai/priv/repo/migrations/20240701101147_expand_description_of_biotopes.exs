defmodule Swai.Repo.Migrations.ExpandDescriptionOfBiotopes do
  use Ecto.Migration

  def change do
    alter table(:biotopes) do
      modify(:description, :text)
    end

  end
end
