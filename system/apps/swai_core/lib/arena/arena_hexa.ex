defmodule Arena.Hexa do
  @moduledoc """
  Swai.Schema.Arena.Hexa contains the Ecto schema for the Hexa.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Arena.Hexa, as: Hexa

  require Logger
  require Jason.Encoder

  @directions %{
    west: {-1, 0},
    northwest: {0, -1},
    north: {1, -1},
    northeast: {1, 0},
    east: {1, 1},
    southeast: {0, 1},
    south: {-1, 1},
    southwest: {-1, 0}
  }

  @all_fields [:q, :r]

  @primary_key false
  @derive {Jason.Encoder, only: @all_fields}
  embedded_schema do
    field(:q, :integer, default: 0)
    field(:r, :integer, default: 0)
  end

  def changeset(seed, nil),
    do: seed

  def changeset(hexa, attrs)
      when is_map(attrs) do
    hexa
    |> cast(attrs, @all_fields)
    |> validate_required(@all_fields)
  end

  def changeset(hexa, attrs)
      when is_struct(attrs),
      do: changeset(hexa, Map.from_struct(attrs))

  def from_map(seed, attrs) do
    case changeset(seed, attrs) do
      %{valid?: true} = changes ->
        {:ok, apply_changes(changes)}

      changeset ->
        {:error, changeset}
    end
  end

  def new(q, r) do
    %Hexa{q: q, r: r}
  end

  def cartesian_to_axial(nil, _), do: nil

  @doc """
  Converts Cartesian coordinates (x, y) to axial coordinates (q, r).

  ## Parameters
    - width: Width of the grid
    - height: Height of the grid
    - hexagon_size: Size of the hexagon
    - point: Tuple representing the Cartesian coordinates (x, y)

  ## Returns
    - A tuple of axial coordinates (q, r)
  """
  def cartesian_to_axial(%{x: x, y: y}, hexagon_size) do
    # Calculate the horizontal and vertical spacing
    horizontal_spacing = hexagon_size * 3 / 2
    vertical_spacing = hexagon_size * :math.sqrt(3)

    # Calculate the axial coordinates (q, r)
    q = x / horizontal_spacing
    r = (y * 2 / vertical_spacing - q) / 2

    %{q: round(q), r: round(r)}
  end

  def axial_to_cartesian(nil), do: nil

  @doc """
  Converts axial coordinates (q, r) to Cartesian coordinates (x, y).

  ## Parameters
    - hexagon_size: Size of the hexagon
    - {q, r}: Tuple representing the axial coordinates (q, r)

  ## Returns
    - A tuple of Cartesian coordinates (x, y)
  """
  def axial_to_cartesian(hexagon_size, %{q: q, r: r}) do
    # Calculate the horizontal and vertical spacing
    horizontal_spacing = hexagon_size * 3 / 2
    vertical_spacing = hexagon_size * :math.sqrt(3)

    # Calculate Cartesian coordinates (x, y)
    x = q * horizontal_spacing
    y = (r + q / 2) * vertical_spacing

    %{x: x, y: y}
  end

  @doc """
  Moves in the specified direction from the given axial coordinates (q, r) for N steps.

  ## Parameters
    - {q, r}: Tuple representing the starting axial coordinates (q, r)
    - direction: One of :west, :northwest, :north, :northeast, :east, :southeast, :south, :southwest
    - steps: Number of steps to move in the given direction

  ## Returns
    - A tuple of new axial coordinates (q, r) after movement
  """
  def move({q, r}, direction, steps) when is_integer(steps) and steps >= 0 do
    {dq, dr} = Map.get(@directions, direction)

    new_q = q + dq * steps
    new_r = r + dr * steps

    {new_q, new_r}
  end

  @doc """
  Moves in the specified directions from the given axial coordinates (q, r) for N steps.
  This function accepts a list of directions to move sequentially.

  ## Parameters
    - {q, r}: Tuple representing the starting axial coordinates (q, r)
    - directions: List of directions to move in
    - steps: Number of steps to move in the specified directions

  ## Returns
    - A tuple of new axial coordinates (q, r) after movement
  """
  def move_multiple({q, r}, directions, steps) when is_integer(steps) and steps >= 0 do
    Enum.reduce(directions, {q, r}, fn direction, {current_q, current_r} ->
      move({current_q, current_r}, direction, steps)
    end)
  end
end
