defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """

  @doc """
  main() takes a string and returns a struct with the following fields:
  hex: the hexadecimal representation of the hash of the input string

  ## Example
      iex> Identicon.main("bananas")
      :ok

  """
  @spec main(String.t) :: atom
  def main(input) do
    input
      |> hash_input
      |> pick_color
      |> build_grid
      |> filter_odd_squares
      |> build_pixel_map
      |> draw_image
      |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  @spec draw_image(Identicon.Image) :: :egd.egd_image()
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    img = :egd.create(250,250)
    fill = :egd.color(color)
    pixel_map
    |> Enum.each( fn({start, stop}) ->
          :egd.filledRectangle(img, start,stop,fill)
         end )
    :egd.render(img)
  end

  @spec build_pixel_map(Identicon.Image) :: Identicon.Image
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      grid
        |> Enum.map( fn({_code, index})  ->
            horizontal = rem(index, 5) * 50
            vertical = div(index, 5) * 50
            top_left = {horizontal, vertical}
            bottom_right = {horizontal + 50, vertical + 50}
            {top_left, bottom_right}
          end )
    %Identicon.Image{image | pixel_map: pixel_map}
  end
  
  
  @spec filter_odd_squares(Identicon.Image) :: list
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    new_grid =
    grid
      |> Enum.filter(fn({code,_index}) ->
           rem(code,2) == 0
         end)
    %Identicon.Image{image | grid: new_grid}
  end

  @spec build_grid(Identicon.Image) :: Identicon.Image
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
        |> Enum.chunk(3)  # create a new list of lists of 3 elements each
        |> Enum.map(&mirror_row/1)
        |> List.flatten
        |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end


  @spec pick_color(Identicon.Image) :: Identicon.Image
#  def pick_color(image) do
  def pick_color(%Identicon.Image{hex: [r,g,b | _tail ]} = image) do
#    Pattern match the first 3 elements of the hash.
#    %Identicon.Image{hex: [r,g,b | _tail ]} = image
#    REFACTORING
#    And bring the first line to the parameter list!
#    Take the original image and return a new image with the color set to the RGB values of the hash.
    %Identicon.Image{image | color: {r,g,b}}
  end


  @spec hash_input(list) :: Identicon.Image
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
  end






end
