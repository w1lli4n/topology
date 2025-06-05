defmodule TopologyTest do
  use ExUnit.Case
  doctest Topology

  test "greets the world" do
    assert Topology.hello() == :world
  end
end
