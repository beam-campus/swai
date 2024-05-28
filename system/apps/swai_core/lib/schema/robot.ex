defmodule Schema.Robot do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Schema.Robot contains the Ecto schema for a Robbot
  """
  alias Schema.Life, as: Life
  alias Schema.Robot, as: Robot
  alias Schema.Id, as: Id

  @status [
    unknown: 0,
    inactive: 1,
    active: 2,
    idle: 4,
    milking: 8,
    cleaning: 16
  ]

  def robot_status(key) do
    @status[key]
  end

  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:stable_id, :string)
    field(:name, :string)
    field(:status, :integer)
  end

  @fields [:id, :name, :status, :stable_id]
  @required_fields [:id, :name, :status, :stable_id]

  defp id_prefix, do: "robot"

  def start_milking(%Robot{} = robot, %Life{} = _life) do
    case changeset(robot, %{
           status: robot.status || robot_status(:milking)
         }) do
      %{valid?: true} = changeset ->
        new_robot =
          changeset
          |> Ecto.Changeset.apply_changes()

        {:ok, new_robot}

      changeset ->
        {:error, changeset}
    end
  end

  def changeset(%Robot{} = robot, %{} = attrs) do
    robot
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end

  def new(name) when is_bitstring(name) do
    defaults = %{
      id: Id.new(id_prefix()) |> Id.as_string(),
      name: name,
      status: robot_status(:unknown)
    }

    new(defaults)
  end

  def new(%{} = attrs) when is_map(attrs) do
    case changeset(%Robot{id: Id.new(id_prefix())}, attrs) do
      %{valid?: true} = changeset ->
        robot =
          changeset
          |> Ecto.Changeset.apply_changes()

        {:ok, robot}

      changeset ->
        {:error, changeset}
    end
  end
end
