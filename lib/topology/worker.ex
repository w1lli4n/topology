defmodule Topology.Worker do
  def run do
    {:job, "Running on external node #{Node.self()}"}
  end
end
