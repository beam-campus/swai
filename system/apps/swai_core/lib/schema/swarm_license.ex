defmodule Schema.SwarmLicense do
  @moduledoc """
  The schema for the License model.
  """
  alias Schema.SwarmLicense

  use Ecto.Schema

  import Ecto.Changeset

  require Logger

  @all_fields [
    :id,
    :biotope_id,
    :user_id,
    :valid_from,
    :valid_until,
    :license_type,
    :max_generations,
    :max_population,
    :is_active?,
    :is_realistic?
  ]

  @required_fields [
    :id,
    :biotope_id,
    :user_id,
    :valid_from,
    :valid_until,
    :license_type,
    :max_generations,
    :max_population,
  ]

  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:biotope_id, :string)
    field(:user_id, :string)
    field(:valid_from, :utc_datetime_usec)
    field(:valid_until, :utc_datetime_usec)
    # Free
    field(:license_type, :integer, default: 1)
    field(:max_generations, :integer, default: 1000)
    field(:max_population, :integer, default: 20)
    field(:is_active?, :boolean, default: false)
    field(:is_realistic?, :boolean, default: false)
  end

  def changeset(%SwarmLicense{} = license, %{} = attrs) do
    license
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
  end

  def from_map(%{} = map) do
    Logger.alert("map: #{inspect(map)}")
    struct = %Schema.SwarmLicense{}

    case changeset(struct, map) do
      %{valid?: true} = changeset ->
        res =
          changeset
          |> apply_changes()

        {:ok, res}

      changeset ->
        Logger.error("Error in changeset: #{inspect(changeset)}")
        {:error, changeset}
    end
  end
end
