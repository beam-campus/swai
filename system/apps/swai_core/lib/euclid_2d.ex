defmodule Euclid2D do

  @moduledoc """
  Euclid2D is a module that contains functions for 2D Euclidean geometry
  """

  require Logger

  import :math

  alias Schema.Vector, as: Vector


  def distance(%Vector{} = here, %Vector{} = there) do
    sqrt(pow((here.x - there.x),2) + pow((here.y - there.y),2))
  end

  def heading(%Vector{} = from, %Vector{} = to) do
    atan2(to.y - from.y, to.x - from.x)
  end

  def orth_heading(%Vector{} = from, %Vector{} = to) do
    heading = heading(from, to)
    heading + (:math.pi / 2)
  end

  def away_heading(%Vector{} = from, %Vector{} = to) do
    atan2(from.y - to.y, from.x - to.x)
    # heading = heading(from, to)
    # heading + :math.pi
  end

  def calculate_endpoint(%Vector{} = here , heading, d) do
    new_x = round(here.x + (d * cos(heading)))
    new_y = round(here.y + (d * sin(heading)))

    %Vector{x: new_x, y: new_y, z: here.z}
  end

  def angle_between_vectors(vector1, vector2) do
    dot_product = vector1.x * vector2.x + vector1.y * vector2.y + vector1.z * vector2.z
    angle = :math.acos(dot_product)
    angle * 180 / :math.pi()
  end



  # Helper functions
  def calculate_speed_vector({px, py, pz}, delta_t) do
    {:ok, %Vector{x: px / delta_t, y: py / delta_t, z: pz / delta_t}}
  end

  def speed_magnitude(%Vector{x: x, y: y, z: z}) do
    :math.sqrt(x * x + y * y + z * z)
  end

  def calculate_position_change({xo, yo, zo}, speed_vector, delta_t) do
    %Vector{
      x: speed_vector.x * delta_t + xo,
      y: speed_vector.y * delta_t + yo,
      z: speed_vector.z * delta_t + zo
    }
  end

  def new_position({xo, yo, zo}, {dx, dy, dz}) do
    %Vector{x: xo + dx, y: yo + dy, z: zo + dz}
  end



end
