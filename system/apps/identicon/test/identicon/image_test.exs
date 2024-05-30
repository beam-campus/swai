defmodule Identicon.ImageTest do
  use ExUnit.Case

  alias Identicon.Image

  @moduletag :capture_log

  doctest Image

  test "module exists" do
    assert is_list(Image.module_info())
  end
end
