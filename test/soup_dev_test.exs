defmodule SoupDevTest do
  use ExUnit.Case
  doctest SoupDev

  test "greets the world" do
    assert SoupDev.hello() == :world
  end
end
