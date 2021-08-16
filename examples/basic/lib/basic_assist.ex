defmodule BasicAs do
  use ExRay, pre: :before_fun, post: :after_fun

  require Logger

  alias ExRay.Span

  use ExRayAssist, ignore_trace: [], get_trace_id: :g

  def fred(a, b), do: a+b

  def g(ctx) do
    "123"
  end
end