defmodule IdenticonTest do
  use ExUnit.Case
  doctest Identicon

  test "that main() always returns the same hash for a given input" do
    input = "bananas"
    hash1 = Identicon.main(input)
    assert is_atom(hash1)

    hash2 = Identicon.main(input)
    assert is_atom(hash2)

    assert hash1 == hash2
  end

end
