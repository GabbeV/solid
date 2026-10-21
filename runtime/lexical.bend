# Immutable const [read, set] bindings in the admitted user program grammar.
# Depth zero is innermost. Nested signal blocks shadow this binder; roots and
# newly constructed compute/application closures capture it without rebinding it.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./callable.bend as Callable

def bind(expr: R.Expr, +depth: Nat, +signal: Nat) -> R.Expr:
  match expr:
    case R.LocalRead{+index}:
      B.choose(~R.Expr, Nat.is_eq(index, depth), _ => R.Read{signal}, _ => R.LocalRead{index})
    case R.LocalAccessor{+index}:
      B.choose(~R.Expr, Nat.is_eq(index, depth), _ => R.Literal{Callable.accessor(signal)}, _ => R.LocalAccessor{index})
    case R.LocalSetter{+index}:
      B.choose(~R.Expr, Nat.is_eq(index, depth), _ => R.Literal{Callable.setter(signal)}, _ => R.LocalSetter{index})
    case R.LocalWrite{+index, value, +updater}:
      +value = bind(value, depth, signal)
      B.choose(~R.Expr, Nat.is_eq(index, depth), _ => R.InvokeWith{R.Literal{Callable.setter(signal)}, value, updater}, _ => R.LocalWrite{index, value, updater})
    case R.SignalComputeScope{compute, options, body}:
      R.SignalComputeScope{bind(compute, depth, signal), options, bind(body, 1n+depth, signal)}
    case R.SignalScope{initial, options, body}:
      R.SignalScope{bind(initial, depth, signal), options, bind(body, 1n+depth, signal)}
    case R.WriteExpr{id, value, updater}:
      R.WriteExpr{id, bind(value, depth, signal), updater}
    case R.Add{left, right}:
      R.Add{bind(left, depth, signal), bind(right, depth, signal)}
    case R.Multiply{left, right}:
      R.Multiply{bind(left, depth, signal), bind(right, depth, signal)}
    case R.Same{left, right}:
      R.Same{bind(left, depth, signal), bind(right, depth, signal)}
    case R.Select{condition, yes, no}:
      R.Select{bind(condition, depth, signal), bind(yes, depth, signal), bind(no, depth, signal)}
    case R.Untracked{body}:
      R.Untracked{bind(body, depth, signal)}
    case R.ActionInvoke{factory, methods}:
      R.ActionInvoke{bind(factory, depth, signal), bind(methods, depth, signal)}
    case R.ActionMethods{next, catches, thrown, tail}:
      R.ActionMethods{bind(next, depth, signal), catches, bind(thrown, depth, signal), bind(tail, depth, signal)}
    case R.IteratorResult{done, value}:
      R.IteratorResult{done, bind(value, depth, signal)}
    case R.FlushCallback{body}:
      R.FlushCallback{bind(body, depth, signal)}
    case R.FlushValue{callee}:
      R.FlushValue{bind(callee, depth, signal)}
    case R.WithOwner{owner, body}:
      R.WithOwner{bind(owner, depth, signal), bind(body, depth, signal)}
    case R.OwnerDisposed{owner}:
      R.OwnerDisposed{bind(owner, depth, signal)}
    case R.DisposeRoot{owner}:
      R.DisposeRoot{bind(owner, depth, signal)}
    case R.CallWith{callback, left, right}:
      R.CallWith{callback, bind(left, depth, signal), bind(right, depth, signal)}
    case R.RootScope{body, transparent}:
      R.RootScope{bind(body, depth, signal), transparent}
    case R.MemoAccessor{compute, options}:
      R.MemoAccessor{bind(compute, depth, signal), options}
    case R.MemoRead{compute, options}:
      R.MemoRead{bind(compute, depth, signal), options}
    case R.EffectCreate{+compute, spec}:
      match spec:
        case R.EffectSpec{+user, +target, +options, +scheduled, +deferred, +program, +cleanup, +error, body}:
          match body:
            case R.NoInlineBody{}:
              R.EffectCreate{bind(compute, depth, signal), R.EffectSpec{user, target, options, scheduled, deferred, program, cleanup, error, R.NoInlineBody{}}}
            case R.SomeInlineBody{expr, returnsCleanup}:
              R.EffectCreate{bind(compute, depth, signal), R.EffectSpec{user, target, options, scheduled, deferred, program, cleanup, error, R.SomeInlineBody{bind(expr, depth, signal), returnsCleanup}}}
    case R.ReactionCreate{body, errorProgram, options, scheduled}:
      R.ReactionCreate{bind(body, depth, signal), errorProgram, options, scheduled}
    case R.ReactionArm{callee, tracking}:
      R.ReactionArm{bind(callee, depth, signal), bind(tracking, depth, signal)}
    case R.ReactionFire{reaction, node}:
      R.ReactionFire{reaction, bind(node, depth, signal)}
    case R.OnSettled{body}:
      R.OnSettled{bind(body, depth, signal)}
    case R.TrackedCreate{body}:
      R.TrackedCreate{bind(body, depth, signal)}
    case R.ContextGet{key, owner}:
      R.ContextGet{key, bind(owner, depth, signal)}
    case R.ContextSet{key, value, owner}:
      R.ContextSet{key, bind(value, depth, signal), bind(owner, depth, signal)}
    case R.InvokeArguments{callee, a, b}:
      R.InvokeArguments{bind(callee, depth, signal), bind(a, depth, signal), bind(b, depth, signal)}
    case R.InvokeWith{callee, value, updater}:
      R.InvokeWith{bind(callee, depth, signal), bind(value, depth, signal), updater}
    case R.Invoke{callee}:
      R.Invoke{bind(callee, depth, signal)}
    case R.OnCleanup{callee}:
      R.OnCleanup{bind(callee, depth, signal)}
    case R.WatchExpr{awaiter, body}:
      R.WatchExpr{awaiter, bind(body, depth, signal)}
    case R.Then{left, right}:
      R.Then{bind(left, depth, signal), bind(right, depth, signal)}
    case other:
      other
