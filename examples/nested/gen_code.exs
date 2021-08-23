defoverridable(blee: 2)
 ############################# 
def(blee(a, b)) do
  ctx = %ExRay.Context{target: :blee, args: [a, b], guards: [], meta: [kind: :coolness]}
  pre = before_fun(ctx)
  try do
    super(a, b)
  rescue
    err ->
      after_fun(ctx, pre, err)
      throw(err)
  else
    res ->
      after_fun(ctx, pre, res)
      res
  end
end
 ############################# 
defoverridable(fred: 2)
 ############################# 
def(fred(a, b)) do
  ctx = %ExRay.Context{target: :fred, args: [a, b], guards: [], meta: [kind: :critical]}
  pre = before_fun(ctx)
  try do
    super(a, b)
  rescue
    err ->
      after_fun(ctx, pre, err)
      throw(err)
  else
    res ->
      after_fun(ctx, pre, res)
      res
  end
end
 ############################# 
