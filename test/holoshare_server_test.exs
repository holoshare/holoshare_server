defmodule HoloshareServerTest do
  use ExUnit.Case
  doctest HoloshareServer

  test "greets the world" do
    assert HoloshareServer.hello() == :world
  end
end
