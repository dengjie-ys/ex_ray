defmodule ExRayAssist do
    defmacro __using__(env) do
        quote do
          require Logger
          import ExRayAssist
          alias ExRay.Span
          __MODULE__ |> Module.put_attribute(:ignore_trace, unquote(env))
          @on_definition { unquote(__MODULE__), :__on_definition__}

            # Generates a request id
          @req_id :os.system_time(:milli_seconds) |> Integer.to_string
          # Called before the annotated function fred is called. Allows to start
          # a span and decorate it with tags and log information
          defp before_fun(ctx) do
            Logger.debug(">>> Starting span for `#{ctx.target}...")
            ctx.target
            |> Span.open(@req_id)
            |> :otter.tag(:kind, ctx.meta[:kind])
            |> :otter.log(">>> #{ctx.target} with #{ctx.args |> inspect}")
          end

          # Called once the annotated function is called. In this hook you can
          # add addtional span info and close the span as we are all done here.
          defp after_fun(ctx, span, res) do
            Logger.debug("<<< Closing span for `#{ctx.target}...")
            span
            |> :otter.log("<<< #{ctx.target} returned #{res |> inspect}")
            |> Span.close(@req_id)
          end

             
        end
    end

    def __on_definition__(env, kind, name, args, guards, body) do
    ignore_func = env.module |> Module.get_attribute(:ignore_trace)
      if Enum.all?(ignore_func, &(&1 != name)) do
            Module.put_attribute(env.module, :trace, [kind:  :c])
      end 
    end

end
