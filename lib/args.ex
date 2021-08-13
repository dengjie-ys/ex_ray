defmodule ExRay.Args do
  @moduledoc false

  @doc """
  Expand_ignored ensures that all ignored arguments are
  expanded when calling wrapping span function.
  """
  @spec expand_ignored([any]) :: [any]
  def expand_ignored(args) do
    args
    |> Enum.map(fn(arg) ->
      arg
      |> case do
        {:%{}, l, m}         -> {:%{}, l, m |> expand_ignored}
        [{k, {a, l, m}} | t] -> [{k, {a |> unignore, l, m}} | t |> expand_ignored]
        {k, {a, l, m}}       -> {k, {a |> unignore, l, m}}
        {a, l, m}            -> {a |> unignore, l, m}
        nil                  -> nil
      end
    end)
  end

  defp unignore(arg) do
    a = arg |> Atom.to_string()
    a
    |> String.starts_with?("_")
    |> case do
      true  -> a |> String.replace_leading("_", "") |> String.to_atom
      false -> arg
    end
  end


  def get_param_name(arg) do
    arg
    |> case do
      {f, l, [name, match]} -> name
      a -> a
      end
  end
end
