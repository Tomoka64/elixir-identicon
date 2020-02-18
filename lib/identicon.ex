defmodule Identicon do
  def main(input) do
    input
    |> hash
    |> pick_color
    |> build_grid
    |> filter
    |> build_image_map
    |> set_up
    |> generate(input)
  end

  def hash(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror/1)
      |> List.flatten
      |> Enum.with_index
    %Identicon.Image{image| grid: grid}
  end

  def mirror(row) do
    [first, second | _tail] = row
    row ++ [first, second]
  end

  def filter(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  def build_image_map(%Identicon.Image{grid: grid} = image) do
    image_map = Enum.map grid, fn({_code, index}) ->
      row = rem(index, 5) * 50
      col = div(index, 5) * 50

      top_left = {row, col}
      bottom_right = {row+50, col+50}

      {top_left, bottom_right}
    end
    %Identicon.Image{image | image_map: image_map}
  end

  def set_up(%Identicon.Image{color: color, image_map: image_map} = _image) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each image_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def generate(image, input) do
    File.write("example/#{input}.png", image)
  end
end
