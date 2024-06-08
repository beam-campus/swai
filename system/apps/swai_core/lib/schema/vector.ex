defmodule Schema.Vector do
  use Ecto.Schema

  @moduledoc """
  Schema.Vector is the module that contains the vector schema
  """

  import Ecto.Changeset
  alias Schema.Vector, as: Vector

  @all_fields [
    :x,
    :y,
    :z
  ]

  @flat_fields [
    :x,
    :y,
    :z
  ]

  @required_fields [
    :x,
    :y,
    :z
  ]

  @derive {Jason.Encoder, only: @all_fields}
  @primary_key false
  embedded_schema do
    field(:x, :float)
    field(:y, :float)
    field(:z, :integer)
  end

  def from_map(map) do
    case changeset(%Vector{}, map) do
      %{valid?: true} = changeset ->
        state =
          changeset
          |> Ecto.Changeset.apply_changes()

        {:ok, state}

      changeset ->
        {:error, changeset}
    end
  end

  def new(x, y, z) do
    %Schema.Vector{
      x: x,
      y: y,
      z: z
    }
  end

  def add(%Vector{} = vector1, %Vector{} = vector2) do
    new(
      vector1.x + vector2.x,
      vector1.y + vector2.y,
      vector1.z + vector2.z
    )
  end

  def substract(%Vector{} = vector1, %Vector{} = vector2) do
    new(
      vector1.x - vector2.x,
      vector1.y - vector2.y,
      vector1.z - vector2.z
    )
  end

  def as_tuple(%Vector{} = vector) do
    {vector.x, vector.y, vector.z}
  end

  defp new_val(val, _max_val) when val < 0,
    do: 0

  defp new_val(val, max_val) when val > max_val,
    do: max_val

  defp new_val(val, max_val) when val <= max_val and val >= 0 do
    case val do
      ^max_val ->
        val - 1 + random_sign()

      0 ->
        val + 1 + random_sign()

      _ ->
        val + random_sign()
    end
  end

  def new_val(origin, relative, max_val, :increase_distance) do
    case max_val do
      ^origin ->
        origin - relative + 1

      0 ->
        origin + 1 + random_sign()

      _ ->
        origin + random_sign()
    end
  end

  def increase_distance({vector1, origin, max_dimensions}) do
    x = new_val(vector1.x, origin.x, max_dimensions.x, :increase_distance)
    y = new_val(vector1.y, origin.y, max_dimensions.y, :increase_distance)
    z = new_val(vector1.z, origin.z, max_dimensions.z, :increase_distance)
    new(x, y, z)
  end

  def new_position(%Vector{} = pos, %Vector{} = world_dimensions) do
    x = new_val(pos.x, world_dimensions.x)
    y = new_val(pos.y, world_dimensions.y)
    z = world_dimensions.z
    new(x, y, z)
  end

  def random_sign() do
    case :rand.uniform(3) do
      1 ->
        0

      2 ->
        1

      _ ->
        -1
    end
  end

  def random_from(%Vector{} = vector) do
    x = vector.x + random_sign()
    y = vector.y + random_sign()
    z = vector.z
    new(x, y, z)
  end

  def random(max_x, max_y, max_z) do
    x = :rand.uniform(max_x)
    y = :rand.uniform(max_y)
    z = :rand.uniform(max_z)
    new(x, y, z)
  end

  def changeset(vector, attr) do
    vector
    |> cast(attr, @flat_fields)
    |> validate_required(@required_fields)
  end
end
