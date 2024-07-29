defmodule Flags do
  import Bitwise

  # def set(target, flag), do: bor(target, flag)
  def set(target, flag), do: target ||| flag
  def unset(target, flag), do: bxor(target, flag)

  def has?(target, flag), do: (target &&& flag) == flag
  def has_not?(target, flag), do: (target &&& flag) != flag

  def to_list(0, flag_map), do: [flag_map[0]]
  def to_list(n, flag_map) when n > 0 do
    # Extract keys (powers of 2) from the map and sort them
    keys = Map.keys(flag_map) |> Enum.sort()
    # Iterate through the keys and collect the flags that are set in `n`
    flags =
      Enum.reduce(keys, [], fn key, acc ->
        if Bitwise.band(n, key) != 0 do
          [flag_map[key] | acc]
        else
          acc
        end
      end)
    # Since we collected the flags in reverse order, reverse the list before returning
    Enum.reverse(flags)
  end

  def highest(n, flag_map) do
    [head | _] =
      to_list(n, flag_map)
      |> Enum.reverse()

    head
  end

  def lowest(n, flag_map) do
    [head | _] =
      to_list(n, flag_map)

    head
  end

  def to_string(n, flag_map) do
    to_list(n, flag_map)
    |> Enum.join(", ")
  end


end
