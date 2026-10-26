# Parameter binding for the defunctionalized user-code ABI. This substitutes
# data for lexical argument occurrences; it contains no Solid scheduling logic.
# RootScope introduces a fresh initializer binder, so its body is left alone.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def argument(+index: Nat, +first: R.Value, second: R.Value) -> R.Value:
  B.choose(~R.Value, Nat.is_eq(index, 0n), _ => first,
    _ => B.choose(~R.Value, Nat.is_eq(index, 1n), _ => second, _ => R.Undefined{}))

# Internal source call sites retain the pair form; user-call vectors have no
# fixed arity. This data binds user syntax and makes no reactive decisions.
type Arguments is Data:
  Pair{first: R.Value, second: R.Value}
  Many{values: List<&2, R.Value>}

def at(+index: Nat, args: Arguments) -> R.Value:
  match args:
    case Pair{first, second}:
      argument(index, first, second)
    case Many{values}:
      B.get(R.Value, values, index, R.Undefined{})

def bindWith(expr: R.Expr, +args: Arguments) -> R.Expr:
  match expr:
    case R.MapArrayCreate{+list, +mapper, fallback, +keyed}:
      match fallback:
        case R.NoInlineBody{}:
          R.MapArrayCreate{bindWith(list, args), bindWith(mapper, args), R.NoInlineBody{}, bindWith(keyed, args)}
        case R.SomeInlineBody{expr, returns}:
          R.MapArrayCreate{bindWith(list, args), bindWith(mapper, args), R.SomeInlineBody{bindWith(expr, args), returns}, bindWith(keyed, args)}
    case R.ArrayLiteral{values}:
      R.ArrayLiteral{bindWith(values, args)}
    case R.ArrayAt{array, index}:
      R.ArrayAt{bindWith(array, args), bindWith(index, args)}
    case R.ArrayLength{array}:
      R.ArrayLength{bindWith(array, args)}
    case R.Flatten{array, skip, defer}:
      R.Flatten{bindWith(array, args), skip, defer}
    case R.RepeatCreate{+count, +mapper, from, fallback}:
      match from fallback:
        case R.NoInlineBody{} R.NoInlineBody{}:
          R.RepeatCreate{bindWith(count, args), bindWith(mapper, args), R.NoInlineBody{}, R.NoInlineBody{}}
        case R.SomeInlineBody{expr, returns} R.NoInlineBody{}:
          R.RepeatCreate{bindWith(count, args), bindWith(mapper, args), R.SomeInlineBody{bindWith(expr, args), returns}, R.NoInlineBody{}}
        case R.NoInlineBody{} R.SomeInlineBody{expr, returns}:
          R.RepeatCreate{bindWith(count, args), bindWith(mapper, args), R.NoInlineBody{}, R.SomeInlineBody{bindWith(expr, args), returns}}
        case R.SomeInlineBody{fromExpr, fromReturns} R.SomeInlineBody{fallbackExpr, fallbackReturns}:
          R.RepeatCreate{bindWith(count, args), bindWith(mapper, args), R.SomeInlineBody{bindWith(fromExpr, args), fromReturns}, R.SomeInlineBody{bindWith(fallbackExpr, args), fallbackReturns}}
    case R.Argument{index}:
      R.Literal{at(index, args)}
    case R.Add{left, right}:
      R.Add{bindWith(left, args), bindWith(right, args)}
    case R.Multiply{left, right}:
      R.Multiply{bindWith(left, args), bindWith(right, args)}
    case R.Affects{left, right}:
      R.Affects{bindWith(left, args), bindWith(right, args)}
    case R.Same{left, right}:
      R.Same{bindWith(left, args), bindWith(right, args)}
    case R.Select{condition, yes, no}:
      R.Select{bindWith(condition, args), bindWith(yes, args), bindWith(no, args)}
    case R.Latest{body}:
      R.Latest{bindWith(body, args)}
    case R.IsPending{body}:
      R.IsPending{bindWith(body, args)}
    case R.Untracked{body}:
      R.Untracked{bindWith(body, args)}
    case R.ActionCreate{factory, methods}:
      R.ActionCreate{bindWith(factory, args), methods}
    case R.ActionInvoke{factory, methods}:
      R.ActionInvoke{bindWith(factory, args), methods}
    case R.IteratorResult{done, value}:
      R.IteratorResult{done, bindWith(value, args)}
    case R.FlushCallback{body}:
      R.FlushCallback{bindWith(body, args)}
    case R.FlushValue{callee}:
      R.FlushValue{bindWith(callee, args)}
    case R.WithOwner{owner, body}:
      R.WithOwner{bindWith(owner, args), bindWith(body, args)}
    case R.OwnerDisposed{owner}:
      R.OwnerDisposed{bindWith(owner, args)}
    case R.DisposeRoot{owner, self}:
      R.DisposeRoot{bindWith(owner, args), self}
    case R.CallWith{callback, left, right}:
      R.CallWith{callback, bindWith(left, args), bindWith(right, args)}
    case R.OptimisticComputeScope{compute, options, body}:
      R.OptimisticComputeScope{bindWith(compute, args), options, bindWith(body, args)}
    case R.SignalComputeScope{compute, options, body}:
      R.SignalComputeScope{bindWith(compute, args), options, bindWith(body, args)}
    case R.OptimisticScope{initial, options, body}:
      R.OptimisticScope{bindWith(initial, args), options, bindWith(body, args)}
    case R.SignalScope{initial, options, body}:
      R.SignalScope{bindWith(initial, args), options, bindWith(body, args)}
    case R.LocalWrite{depth, value, updater}:
      R.LocalWrite{depth, bindWith(value, args), updater}
    case R.WriteExpr{signal, value, updater}:
      R.WriteExpr{signal, bindWith(value, args), updater}
    case R.EffectCreate{compute, spec}:
      R.EffectCreate{bindWith(compute, args), spec}
    case R.ReactionCreate{body, errorProgram, options, scheduled}:
      R.ReactionCreate{bindWith(body, args), errorProgram, options, scheduled}
    case R.ReactionArm{callee, tracking}:
      R.ReactionArm{bindWith(callee, args), bindWith(tracking, args)}
    case R.ReactionFire{reaction, node}:
      R.ReactionFire{reaction, bindWith(node, args)}
    case R.OnSettled{body}:
      R.OnSettled{bindWith(body, args)}
    case R.OnFlush{body}:
      R.OnFlush{bindWith(body, args)}
    case R.TrackedCreate{body}:
      R.TrackedCreate{bindWith(body, args)}
    case R.DeferredAccessor{compute, options}:
      R.DeferredAccessor{bindWith(compute, args), options}
    case R.DeferredRead{compute, options}:
      R.DeferredRead{bindWith(compute, args), options}
    case R.MemoAccessor{compute, options}:
      R.MemoAccessor{bindWith(compute, args), options}
    case R.MemoRead{compute, options}:
      R.MemoRead{bindWith(compute, args), options}
    case R.RootScope{body, transparent}:
      R.RootScope{body, transparent}
    case R.ContextGet{key, owner}:
      R.ContextGet{key, bindWith(owner, args)}
    case R.ContextSet{key, value, owner}:
      R.ContextSet{key, bindWith(value, args), bindWith(owner, args)}
    case R.InvokeMany{callee, values}:
      R.InvokeMany{bindWith(callee, args), bindWith(values, args)}
    case R.CallArgumentsItem{value, tail}:
      R.CallArgumentsItem{bindWith(value, args), bindWith(tail, args)}
    case R.InvokeArguments{callee, a, b}:
      R.InvokeArguments{bindWith(callee, args), bindWith(a, args), bindWith(b, args)}
    case R.InvokeWith{callee, value, updater}:
      R.InvokeWith{bindWith(callee, args), bindWith(value, args), updater}
    case R.Invoke{callee}:
      R.Invoke{bindWith(callee, args)}
    case R.FromInput{callee}:
      R.FromInput{bindWith(callee, args)}
    case R.OnCleanup{callee}:
      R.OnCleanup{bindWith(callee, args)}
    case R.WatchExpr{awaiter, body}:
      R.WatchExpr{awaiter, bindWith(body, args)}
    case R.Then{left, right}:
      R.Then{bindWith(left, args), bindWith(right, args)}
    case other:
      other

def bind(expr: R.Expr, first: R.Value, second: R.Value) -> R.Expr:
  bindWith(expr, Pair{first, second})

def bindMany(expr: R.Expr, values: List<&2, R.Value>) -> R.Expr:
  bindWith(expr, Many{values})
