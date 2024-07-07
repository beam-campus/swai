defmodule Swai.Repo.Migrations.CreateDroneOrders do
  use Ecto.Migration

  def change do
    create table(:drone_orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :string
      add :quantity, :integer
      add :price_in_cents, :integer
      add :currency, :string
      add :status, :integer
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:drone_orders, [:user_id])
  end
end
