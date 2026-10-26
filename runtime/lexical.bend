# Immutable const [read, set] bindings in the admitted user program grammar.
# Depth zero is innermost. Nested signal blocks shadow this binder; roots and
# newly constructed compute/application closures capture it without rebinding it.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./callable.bend as Callable

def bindAs(expr: R.Expr, +depth: Nat, +signal: Nat, +setter: R.Value) -> R.Expr:
  match expr:
    case R.MapArrayCreate{+list, +mapper, fallback, +keyed}:
      match fallback:
        case R.NoInlineBody{}:
          R.MapArrayCreate{bindAs(list, depth, signal, setter), bindAs(mapper, depth, signal, setter), R.NoInlineBody{}, bindAs(keyed, depth, signal, setter)}
        case R.SomeInlineBody{expr, returns}:
          R.MapArrayCreate{bindAs(list, depth, signal, setter), bindAs(mapper, depth, signal, setter), R.SomeInlineBody{bindAs(expr, depth, signal, setter), returns}, bindAs(keyed, depth, signal, setter)}
    case R.ArrayLiteral{values}:
      R.ArrayLiteral{bindAs(values, depth, signal, setter)}
    case R.ArrayAt{array, index}:
      R.ArrayAt{bindAs(array, depth, signal, setter), bindAs(index, depth, signal, setter)}
    case R.ArrayLength{array}:
      R.ArrayLength{bindAs(array, depth, signal, setter)}
    case R.Flatten{array, skip, defer}:
      R.Flatten{bindAs(array, depth, signal, setter), skip, defer}
    case R.RepeatCreate{+count, +mapper, from, fallback}:
      match from fallback:
        case R.NoInlineBody{} R.NoInlineBody{}:
          R.RepeatCreate{bindAs(count, depth, signal, setter), bindAs(mapper, depth, signal, setter), R.NoInlineBody{}, R.NoInlineBody{}}
        case R.SomeInlineBody{expr, returns} R.NoInlineBody{}:
          R.RepeatCreate{bindAs(count, depth, signal, setter), bindAs(mapper, depth, signal, setter), R.SomeInlineBody{bindAs(expr, depth, signal, setter), returns}, R.NoInlineBody{}}
        case R.NoInlineBody{} R.SomeInlineBody{expr, returns}:
          R.RepeatCreate{bindAs(count, depth, signal, setter), bindAs(mapper, depth, signal, setter), R.NoInlineBody{}, R.SomeInlineBody{bindAs(expr, depth, signal, setter), returns}}
        case R.SomeInlineBody{fromExpr, fromReturns} R.SomeInlineBody{fallbackExpr, fallbackReturns}:
          R.RepeatCreate{bindAs(count, depth, signal, setter), bindAs(mapper, depth, signal, setter), R.SomeInlineBody{bindAs(fromExpr, depth, signal, setter), fromReturns}, R.SomeInlineBody{bindAs(fallbackExpr, depth, signal, setter), fallbackReturns}}
    case R.LocalRead{+index}:
      B.choose(~R.Expr, Nat.is_eq(index, depth), _ => R.Read{signal}, _ => R.LocalRead{index})
    case R.LocalAccessor{+index}:
      B.choose(~R.Expr, Nat.is_eq(index, depth), _ => R.Literal{Callable.accessor(signal)}, _ => R.LocalAccessor{index})
    case R.LocalSetter{+index}:
      B.choose(~R.Expr, Nat.is_eq(index, depth), _ => R.Literal{setter}, _ => R.LocalSetter{index})
    case R.LocalWrite{+index, value, +updater}:
      +value = bindAs(value, depth, signal, setter)
      B.choose(~R.Expr, Nat.is_eq(index, depth), _ => R.InvokeWith{R.Literal{setter}, value, updater}, _ => R.LocalWrite{index, value, updater})
    case R.OptimisticComputeScope{compute, options, body}:
      R.OptimisticComputeScope{bindAs(compute, depth, signal, setter), options, bindAs(body, 1n+depth, signal, setter)}
    case R.OptimisticScope{initial, options, body}:
      R.OptimisticScope{bindAs(initial, depth, signal, setter), options, bindAs(body, 1n+depth, signal, setter)}
    case R.SignalComputeScope{compute, options, body}:
      R.SignalComputeScope{bindAs(compute, depth, signal, setter), options, bindAs(body, 1n+depth, signal, setter)}
    case R.SignalScope{initial, options, body}:
      R.SignalScope{bindAs(initial, depth, signal, setter), options, bindAs(body, 1n+depth, signal, setter)}
    case R.WriteExpr{id, value, updater}:
      R.WriteExpr{id, bindAs(value, depth, signal, setter), updater}
    case R.Add{left, right}:
      R.Add{bindAs(left, depth, signal, setter), bindAs(right, depth, signal, setter)}
    case R.Multiply{left, right}:
      R.Multiply{bindAs(left, depth, signal, setter), bindAs(right, depth, signal, setter)}
    case R.Affects{left, right}:
      R.Affects{bindAs(left, depth, signal, setter), bindAs(right, depth, signal, setter)}
    case R.Same{left, right}:
      R.Same{bindAs(left, depth, signal, setter), bindAs(right, depth, signal, setter)}
    case R.Select{condition, yes, no}:
      R.Select{bindAs(condition, depth, signal, setter), bindAs(yes, depth, signal, setter), bindAs(no, depth, signal, setter)}
    case R.Latest{body}:
      R.Latest{bindAs(body, depth, signal, setter)}
    case R.IsPending{body}:
      R.IsPending{bindAs(body, depth, signal, setter)}
    case R.Untracked{body}:
      R.Untracked{bindAs(body, depth, signal, setter)}
    case R.ActionCreate{factory, methods}:
      R.ActionCreate{bindAs(factory, depth, signal, setter), bindAs(methods, depth, signal, setter)}
    case R.ActionInvoke{factory, methods}:
      R.ActionInvoke{bindAs(factory, depth, signal, setter), bindAs(methods, depth, signal, setter)}
    case R.ActionMethods{next, catches, thrown, tail}:
      R.ActionMethods{bindAs(next, depth, signal, setter), catches, bindAs(thrown, depth, signal, setter), bindAs(tail, depth, signal, setter)}
    case R.IteratorResult{done, value}:
      R.IteratorResult{done, bindAs(value, depth, signal, setter)}
    case R.FlushCallback{body}:
      R.FlushCallback{bindAs(body, depth, signal, setter)}
    case R.FlushValue{callee}:
      R.FlushValue{bindAs(callee, depth, signal, setter)}
    case R.WithOwner{owner, body}:
      R.WithOwner{bindAs(owner, depth, signal, setter), bindAs(body, depth, signal, setter)}
    case R.OwnerDisposed{owner}:
      R.OwnerDisposed{bindAs(owner, depth, signal, setter)}
    case R.DisposeRoot{owner, self}:
      R.DisposeRoot{bindAs(owner, depth, signal, setter), self}
    case R.CallWith{callback, left, right}:
      R.CallWith{callback, bindAs(left, depth, signal, setter), bindAs(right, depth, signal, setter)}
    case R.RootScope{body, transparent}:
      R.RootScope{bindAs(body, depth, signal, setter), transparent}
    case R.DeferredAccessor{compute, options}:
      R.DeferredAccessor{bindAs(compute, depth, signal, setter), options}
    case R.DeferredRead{compute, options}:
      R.DeferredRead{bindAs(compute, depth, signal, setter), options}
    case R.MemoAccessor{compute, options}:
      R.MemoAccessor{bindAs(compute, depth, signal, setter), options}
    case R.MemoRead{compute, options}:
      R.MemoRead{bindAs(compute, depth, signal, setter), options}
    case R.EffectCreate{+compute, spec}:
      match spec:
        case R.EffectSpec{+user, +target, +options, +scheduled, +deferred, +program, +cleanup, +error, body}:
          match body:
            case R.NoInlineBody{}:
              R.EffectCreate{bindAs(compute, depth, signal, setter), R.EffectSpec{user, target, options, scheduled, deferred, program, cleanup, error, R.NoInlineBody{}}}
            case R.SomeInlineBody{expr, returnsCleanup}:
              R.EffectCreate{bindAs(compute, depth, signal, setter), R.EffectSpec{user, target, options, scheduled, deferred, program, cleanup, error, R.SomeInlineBody{bindAs(expr, depth, signal, setter), returnsCleanup}}}
    case R.ReactionCreate{body, errorProgram, options, scheduled}:
      R.ReactionCreate{bindAs(body, depth, signal, setter), errorProgram, options, scheduled}
    case R.ReactionArm{callee, tracking}:
      R.ReactionArm{bindAs(callee, depth, signal, setter), bindAs(tracking, depth, signal, setter)}
    case R.ReactionFire{reaction, node}:
      R.ReactionFire{reaction, bindAs(node, depth, signal, setter)}
    case R.OnSettled{body}:
      R.OnSettled{bindAs(body, depth, signal, setter)}
    case R.OnFlush{body}:
      R.OnFlush{bindAs(body, depth, signal, setter)}
    case R.TrackedCreate{body}:
      R.TrackedCreate{bindAs(body, depth, signal, setter)}
    case R.ContextGet{key, owner}:
      R.ContextGet{key, bindAs(owner, depth, signal, setter)}
    case R.ContextSet{key, value, owner}:
      R.ContextSet{key, bindAs(value, depth, signal, setter), bindAs(owner, depth, signal, setter)}
    case R.InvokeMany{callee, values}:
      R.InvokeMany{bindAs(callee, depth, signal, setter), bindAs(values, depth, signal, setter)}
    case R.CallArgumentsItem{value, tail}:
      R.CallArgumentsItem{bindAs(value, depth, signal, setter), bindAs(tail, depth, signal, setter)}
    case R.InvokeArguments{callee, a, b}:
      R.InvokeArguments{bindAs(callee, depth, signal, setter), bindAs(a, depth, signal, setter), bindAs(b, depth, signal, setter)}
    case R.InvokeWith{callee, value, updater}:
      R.InvokeWith{bindAs(callee, depth, signal, setter), bindAs(value, depth, signal, setter), updater}
    case R.Invoke{callee}:
      R.Invoke{bindAs(callee, depth, signal, setter)}
    case R.FromInput{callee}:
      R.FromInput{bindAs(callee, depth, signal, setter)}
    case R.OnCleanup{callee}:
      R.OnCleanup{bindAs(callee, depth, signal, setter)}
    case R.WatchExpr{awaiter, body}:
      R.WatchExpr{awaiter, bindAs(body, depth, signal, setter)}
    case R.Then{left, right}:
      R.Then{bindAs(left, depth, signal, setter), bindAs(right, depth, signal, setter)}
    case other:
      other

# Public ordinary signal binding retains its constructor-selected setter.
def bind(expr: R.Expr, depth: Nat, +signal: Nat) -> R.Expr:
  bindAs(expr, depth, signal, Callable.setter(signal))
