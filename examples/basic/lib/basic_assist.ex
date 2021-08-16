defmodule BasicAs do
  require Logger
  use ExRayAssist, ignore_trace: [], get_trace_id: :g

  def fred(a, b), do: a+b
  def g(ctx) do
    "trace_id"
  end
end