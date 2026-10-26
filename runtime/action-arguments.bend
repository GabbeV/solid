# User-code action parameter capture, separate from generator resume arguments.
# Depth zero is the invoked action; nested ActionCreate introduces a binder.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./callback.bend as Z

def bindWith(expr: R.Expr, +depth: Nat, +args: Z.Arguments) -> R.Expr:
  match expr:
    case R.MapArrayCreate{+list, +mapper, fallback, +keyed}:
      match fallback:
        case R.NoInlineBody{}:
          R.MapArrayCreate{bindWith(list, depth, args), bindWith(mapper, depth, args), R.NoInlineBody{}, bindWith(keyed, depth, args)}
        case R.SomeInlineBody{expr, returns}:
          R.MapArrayCreate{bindWith(list, depth, args), bindWith(mapper, depth, args), R.SomeInlineBody{bindWith(expr, depth, args), returns}, bindWith(keyed, depth, args)}
    case R.ArrayLiteral{values}:
      R.ArrayLiteral{bindWith(values, depth, args)}
    case R.ArrayAt{array, index}:
      R.ArrayAt{bindWith(array, depth, args), bindWith(index, depth, args)}
    case R.ArrayLength{array}:
      R.ArrayLength{bindWith(array, depth, args)}
    case R.Flatten{array, skip, defer}:
      R.Flatten{bindWith(array, depth, args), skip, defer}
    case R.RepeatCreate{+count, +mapper, from, fallback}:
      match from fallback:
        case R.NoInlineBody{} R.NoInlineBody{}:
          R.RepeatCreate{bindWith(count, depth, args), bindWith(mapper, depth, args), R.NoInlineBody{}, R.NoInlineBody{}}
        case R.SomeInlineBody{expr, returns} R.NoInlineBody{}:
          R.RepeatCreate{bindWith(count, depth, args), bindWith(mapper, depth, args), R.SomeInlineBody{bindWith(expr, depth, args), returns}, R.NoInlineBody{}}
        case R.NoInlineBody{} R.SomeInlineBody{expr, returns}:
          R.RepeatCreate{bindWith(count, depth, args), bindWith(mapper, depth, args), R.NoInlineBody{}, R.SomeInlineBody{bindWith(expr, depth, args), returns}}
        case R.SomeInlineBody{fromExpr, fromReturns} R.SomeInlineBody{fallbackExpr, fallbackReturns}:
          R.RepeatCreate{bindWith(count, depth, args), bindWith(mapper, depth, args), R.SomeInlineBody{bindWith(fromExpr, depth, args), fromReturns}, R.SomeInlineBody{bindWith(fallbackExpr, depth, args), fallbackReturns}}
    case R.ActionParameter{+indexDepth, +index}:
      B.choose(~R.Expr, Nat.is_eq(indexDepth, depth),
        _ => R.Literal{Z.at(index, args)},
        _ => R.ActionParameter{indexDepth, index})
    case R.LocalWrite{index, value, updater}:
      R.LocalWrite{index, bindWith(value, depth, args), updater}
    case R.OptimisticComputeScope{compute, options, body}:
      R.OptimisticComputeScope{bindWith(compute, depth, args), options, bindWith(body, depth, args)}
    case R.SignalComputeScope{compute, options, body}:
      R.SignalComputeScope{bindWith(compute, depth, args), options, bindWith(body, depth, args)}
    case R.OptimisticScope{initial, options, body}:
      R.OptimisticScope{bindWith(initial, depth, args), options, bindWith(body, depth, args)}
    case R.SignalScope{initial, options, body}:
      R.SignalScope{bindWith(initial, depth, args), options, bindWith(body, depth, args)}
    case R.WriteExpr{id, value, updater}:
      R.WriteExpr{id, bindWith(value, depth, args), updater}
    case R.Add{left, right}:
      R.Add{bindWith(left, depth, args), bindWith(right, depth, args)}
    case R.Multiply{left, right}:
      R.Multiply{bindWith(left, depth, args), bindWith(right, depth, args)}
    case R.Affects{left, right}:
      R.Affects{bindWith(left, depth, args), bindWith(right, depth, args)}
    case R.Same{left, right}:
      R.Same{bindWith(left, depth, args), bindWith(right, depth, args)}
    case R.Select{condition, yes, no}:
      R.Select{bindWith(condition, depth, args), bindWith(yes, depth, args), bindWith(no, depth, args)}
    case R.Latest{body}:
      R.Latest{bindWith(body, depth, args)}
    case R.IsPending{body}:
      R.IsPending{bindWith(body, depth, args)}
    case R.Untracked{body}:
      R.Untracked{bindWith(body, depth, args)}
    case R.ActionCreate{factory, methods}:
      R.ActionCreate{bindWith(factory, 1n+depth, args), bindWith(methods, 1n+depth, args)}
    case R.ActionInvoke{factory, methods}:
      R.ActionInvoke{bindWith(factory, depth, args), bindWith(methods, depth, args)}
    case R.ActionMethods{next, catches, thrown, tail}:
      R.ActionMethods{bindWith(next, depth, args), catches, bindWith(thrown, depth, args), bindWith(tail, depth, args)}
    case R.IteratorResult{done, value}:
      R.IteratorResult{done, bindWith(value, depth, args)}
    case R.FlushCallback{body}:
      R.FlushCallback{bindWith(body, depth, args)}
    case R.FlushValue{callee}:
      R.FlushValue{bindWith(callee, depth, args)}
    case R.WithOwner{owner, body}:
      R.WithOwner{bindWith(owner, depth, args), bindWith(body, depth, args)}
    case R.OwnerDisposed{owner}:
      R.OwnerDisposed{bindWith(owner, depth, args)}
    case R.DisposeRoot{owner, self}:
      R.DisposeRoot{bindWith(owner, depth, args), self}
    case R.CallWith{callback, left, right}:
      R.CallWith{callback, bindWith(left, depth, args), bindWith(right, depth, args)}
    case R.RootScope{body, transparent}:
      R.RootScope{bindWith(body, depth, args), transparent}
    case R.DeferredAccessor{compute, options}:
      R.DeferredAccessor{bindWith(compute, depth, args), options}
    case R.DeferredRead{compute, options}:
      R.DeferredRead{bindWith(compute, depth, args), options}
    case R.MemoAccessor{compute, options}:
      R.MemoAccessor{bindWith(compute, depth, args), options}
    case R.MemoRead{compute, options}:
      R.MemoRead{bindWith(compute, depth, args), options}
    case R.EffectCreate{+compute, spec}:
      match spec:
        case R.EffectSpec{+user, +target, +options, +scheduled, +deferred, +program, +cleanup, +error, body}:
          match body:
            case R.NoInlineBody{}:
              R.EffectCreate{bindWith(compute, depth, args), R.EffectSpec{user, target, options, scheduled, deferred, program, cleanup, error, R.NoInlineBody{}}}
            case R.SomeInlineBody{expr, returnsCleanup}:
              R.EffectCreate{bindWith(compute, depth, args), R.EffectSpec{user, target, options, scheduled, deferred, program, cleanup, error, R.SomeInlineBody{bindWith(expr, depth, args), returnsCleanup}}}
    case R.ReactionCreate{body, errorProgram, options, scheduled}:
      R.ReactionCreate{bindWith(body, depth, args), errorProgram, options, scheduled}
    case R.ReactionArm{callee, tracking}:
      R.ReactionArm{bindWith(callee, depth, args), bindWith(tracking, depth, args)}
    case R.ReactionFire{reaction, node}:
      R.ReactionFire{reaction, bindWith(node, depth, args)}
    case R.OnSettled{body}:
      R.OnSettled{bindWith(body, depth, args)}
    case R.OnFlush{body}:
      R.OnFlush{bindWith(body, depth, args)}
    case R.TrackedCreate{body}:
      R.TrackedCreate{bindWith(body, depth, args)}
    case R.ContextGet{key, owner}:
      R.ContextGet{key, bindWith(owner, depth, args)}
    case R.ContextSet{key, value, owner}:
      R.ContextSet{key, bindWith(value, depth, args), bindWith(owner, depth, args)}
    case R.InvokeMany{callee, values}:
      R.InvokeMany{bindWith(callee, depth, args), bindWith(values, depth, args)}
    case R.CallArgumentsItem{value, tail}:
      R.CallArgumentsItem{bindWith(value, depth, args), bindWith(tail, depth, args)}
    case R.InvokeArguments{callee, a, b}:
      R.InvokeArguments{bindWith(callee, depth, args), bindWith(a, depth, args), bindWith(b, depth, args)}
    case R.InvokeWith{callee, value, updater}:
      R.InvokeWith{bindWith(callee, depth, args), bindWith(value, depth, args), updater}
    case R.Invoke{callee}:
      R.Invoke{bindWith(callee, depth, args)}
    case R.FromInput{callee}:
      R.FromInput{bindWith(callee, depth, args)}
    case R.OnCleanup{callee}:
      R.OnCleanup{bindWith(callee, depth, args)}
    case R.WatchExpr{awaiter, body}:
      R.WatchExpr{awaiter, bindWith(body, depth, args)}
    case R.Then{left, right}:
      R.Then{bindWith(left, depth, args), bindWith(right, depth, args)}
    case other:
      other

def bind(expr: R.Expr, depth: Nat, first: R.Value, second: R.Value) -> R.Expr:
  bindWith(expr, depth, Z.Pair{first, second})

def bindMany(expr: R.Expr, depth: Nat, values: List<&2, R.Value>) -> R.Expr:
  bindWith(expr, depth, Z.Many{values})
