defmodule ExRayAssist do
  defmacro __using__(env) do
    
    quote do
      require Logger
      import ExRayAssist
      alias ExRay.Span
      use ExRay, pre: :before_fun, post: :after_fun
      __MODULE__
      |> Module.put_attribute(
        :ignore_trace,
        unquote(env |> Keyword.get(:ignore_trace)) ++ [:before_fun, :after_fun]
      )

      __MODULE__
      |> Module.put_attribute(
        :get_trace_id,
        unquote(env |> Keyword.get(:get_trace_id))
      )

      @on_definition {unquote(__MODULE__), :__on_definition__}

      @req_id :os.system_time(:milli_seconds) |> Integer.to_string()
      # Called before the annotated function fred is called. Allows to start
      # a span and decorate it with tags and log information
      def before_fun(ctx) do
        trace_id = unquote(env |> Keyword.get(:get_trace_id))(ctx)
        Logger.debug(">>> Starting span for `#{ctx.target} with trace_id #{trace_id} ...")

        ctx.target
        |> Span.open(trace_id)
        |> :otter.tag(:kind, ctx.meta[:kind])
        |> :otter.log(">>> #{ctx.target} with #{ctx.args |> inspect}")
      end

      # Called once the annotated function is called. In this hook you can
      # add addtional span info and close the span as we are all getne here.
      def after_fun(ctx, span, res) do
        trace_id = unquote(env |> Keyword.get(:get_trace_id))(ctx)
        Logger.debug("<<< Closing span for `#{ctx.target} with trace_id #{trace_id} ...")

        span
        |> :otter.log("<<< #{ctx.target} returned #{inspect(res)}")
        |> Span.close(trace_id)
      end
    end
    
    
  end

  def __on_definition__(env, kind, name, args, guards, body) do
    ignore_func = env.module |> Module.get_attribute(:ignore_trace)
    get_trace_id = env.module |> Module.get_attribute(:get_trace_id)
    if Enum.all?(ignore_func ++ [get_trace_id], &(&1 != name)) do
      Module.put_attribute(env.module, :trace, kind: :c)
    end
  end
end
