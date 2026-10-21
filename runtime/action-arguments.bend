# User-code action parameter capture, separate from generator resume arguments.
# Depth zero is the invoked action; nested ActionCreate introduces a binder.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./callback.bend as Z

def bind(expr: R.Expr, +depth: Nat, +first: R.Value, +second: R.Value) -> R.Expr:
  match expr:
    case R.ActionParameter{+indexDepth, +index}:
      B.choose(~R.Expr, Nat.is_eq(indexDepth, depth),
        _ => R.Literal{Z.argument(index, first, second)},
        _ => R.ActionParameter{indexDepth, index})
    case R.LocalWrite{index, value, updater}:
      R.LocalWrite{index, bind(value, depth, first, second), updater}
    case R.SignalComputeScope{compute, options, body}:
      R.SignalComputeScope{bind(compute, depth, first, second), options, bind(body, depth, first, second)}
    case R.SignalScope{initial, options, body}:
      R.SignalScope{bind(initial, depth, first, second), options, bind(body, depth, first, second)}
    case R.WriteExpr{id, value, updater}:
      R.WriteExpr{id, bind(value, depth, first, second), updater}
    case R.Add{left, right}:
      R.Add{bind(left, depth, first, second), bind(right, depth, first, second)}
    case R.Multiply{left, right}:
      R.Multiply{bind(left, depth, first, second), bind(right, depth, first, second)}
    case R.Same{left, right}:
      R.Same{bind(left, depth, first, second), bind(right, depth, first, second)}
    case R.Select{condition, yes, no}:
      R.Select{bind(condition, depth, first, second), bind(yes, depth, first, second), bind(no, depth, first, second)}
    case R.Untracked{body}:
      R.Untracked{bind(body, depth, first, second)}
    case R.ActionCreate{factory, methods}:
      R.ActionCreate{bind(factory, 1n+depth, first, second), bind(methods, 1n+depth, first, second)}
    case R.ActionInvoke{factory, methods}:
      R.ActionInvoke{bind(factory, depth, first, second), bind(methods, depth, first, second)}
    case R.ActionMethods{next, catches, thrown, tail}:
      R.ActionMethods{bind(next, depth, first, second), catches, bind(thrown, depth, first, second), bind(tail, depth, first, second)}
    case R.IteratorResult{done, value}:
      R.IteratorResult{done, bind(value, depth, first, second)}
    case R.FlushCallback{body}:
      R.FlushCallback{bind(body, depth, first, second)}
    case R.FlushValue{callee}:
      R.FlushValue{bind(callee, depth, first, second)}
    case R.WithOwner{owner, body}:
      R.WithOwner{bind(owner, depth, first, second), bind(body, depth, first, second)}
    case R.OwnerDisposed{owner}:
      R.OwnerDisposed{bind(owner, depth, first, second)}
    case R.DisposeRoot{owner}:
      R.DisposeRoot{bind(owner, depth, first, second)}
    case R.CallWith{callback, left, right}:
      R.CallWith{callback, bind(left, depth, first, second), bind(right, depth, first, second)}
    case R.RootScope{body, transparent}:
      R.RootScope{bind(body, depth, first, second), transparent}
    case R.MemoAccessor{compute, options}:
      R.MemoAccessor{bind(compute, depth, first, second), options}
    case R.MemoRead{compute, options}:
      R.MemoRead{bind(compute, depth, first, second), options}
    case R.EffectCreate{+compute, spec}:
      match spec:
        case R.EffectSpec{+user, +target, +options, +scheduled, +deferred, +program, +cleanup, +error, body}:
          match body:
            case R.NoInlineBody{}:
              R.EffectCreate{bind(compute, depth, first, second), R.EffectSpec{user, target, options, scheduled, deferred, program, cleanup, error, R.NoInlineBody{}}}
            case R.SomeInlineBody{expr, returnsCleanup}:
              R.EffectCreate{bind(compute, depth, first, second), R.EffectSpec{user, target, options, scheduled, deferred, program, cleanup, error, R.SomeInlineBody{bind(expr, depth, first, second), returnsCleanup}}}
    case R.ReactionCreate{body, errorProgram, options, scheduled}:
      R.ReactionCreate{bind(body, depth, first, second), errorProgram, options, scheduled}
    case R.ReactionArm{callee, tracking}:
      R.ReactionArm{bind(callee, depth, first, second), bind(tracking, depth, first, second)}
    case R.ReactionFire{reaction, node}:
      R.ReactionFire{reaction, bind(node, depth, first, second)}
    case R.OnSettled{body}:
      R.OnSettled{bind(body, depth, first, second)}
    case R.TrackedCreate{body}:
      R.TrackedCreate{bind(body, depth, first, second)}
    case R.ContextGet{key, owner}:
      R.ContextGet{key, bind(owner, depth, first, second)}
    case R.ContextSet{key, value, owner}:
      R.ContextSet{key, bind(value, depth, first, second), bind(owner, depth, first, second)}
    case R.InvokeArguments{callee, a, b}:
      R.InvokeArguments{bind(callee, depth, first, second), bind(a, depth, first, second), bind(b, depth, first, second)}
    case R.InvokeWith{callee, value, updater}:
      R.InvokeWith{bind(callee, depth, first, second), bind(value, depth, first, second), updater}
    case R.Invoke{callee}:
      R.Invoke{bind(callee, depth, first, second)}
    case R.OnCleanup{callee}:
      R.OnCleanup{bind(callee, depth, first, second)}
    case R.WatchExpr{awaiter, body}:
      R.WatchExpr{awaiter, bind(body, depth, first, second)}
    case R.Then{left, right}:
      R.Then{bind(left, depth, first, second), bind(right, depth, first, second)}
    case other:
      other
