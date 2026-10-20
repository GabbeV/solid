# Parameter binding for the defunctionalized user-code ABI. This substitutes
# data for lexical argument occurrences; it contains no Solid scheduling logic.
# RootScope introduces a fresh initializer binder, so its body is left alone.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def argument(+index: Nat, +first: R.Value, second: R.Value) -> R.Value:
  B.choose(~R.Value, Nat.is_eq(index, 0n), _ => first,
    _ => B.choose(~R.Value, Nat.is_eq(index, 1n), _ => second, _ => R.Undefined{}))

def bind(expr: R.Expr, +first: R.Value, +second: R.Value) -> R.Expr:
  match expr:
    case R.Argument{index}:
      R.Literal{argument(index, first, second)}
    case R.Add{left, right}:
      R.Add{bind(left, first, second), bind(right, first, second)}
    case R.Multiply{left, right}:
      R.Multiply{bind(left, first, second), bind(right, first, second)}
    case R.Same{left, right}:
      R.Same{bind(left, first, second), bind(right, first, second)}
    case R.Select{condition, yes, no}:
      R.Select{bind(condition, first, second), bind(yes, first, second), bind(no, first, second)}
    case R.Untracked{body}:
      R.Untracked{bind(body, first, second)}
    case R.WithOwner{owner, body}:
      R.WithOwner{bind(owner, first, second), bind(body, first, second)}
    case R.OwnerDisposed{owner}:
      R.OwnerDisposed{bind(owner, first, second)}
    case R.DisposeRoot{owner}:
      R.DisposeRoot{bind(owner, first, second)}
    case R.CallWith{callback, left, right}:
      R.CallWith{callback, bind(left, first, second), bind(right, first, second)}
    case R.SignalComputeScope{compute, options, body}:
      R.SignalComputeScope{bind(compute, first, second), options, bind(body, first, second)}
    case R.SignalScope{initial, options, body}:
      R.SignalScope{bind(initial, first, second), options, bind(body, first, second)}
    case R.LocalWrite{depth, value, updater}:
      R.LocalWrite{depth, bind(value, first, second), updater}
    case R.WriteExpr{signal, value, updater}:
      R.WriteExpr{signal, bind(value, first, second), updater}
    case R.EffectCreate{compute, spec}:
      R.EffectCreate{bind(compute, first, second), spec}
    case R.MemoAccessor{compute, options}:
      R.MemoAccessor{bind(compute, first, second), options}
    case R.MemoRead{compute, options}:
      R.MemoRead{bind(compute, first, second), options}
    case R.RootScope{body, transparent}:
      R.RootScope{body, transparent}
    case R.ContextGet{key, owner}:
      R.ContextGet{key, bind(owner, first, second)}
    case R.ContextSet{key, value, owner}:
      R.ContextSet{key, bind(value, first, second), bind(owner, first, second)}
    case R.InvokeArguments{callee, a, b}:
      R.InvokeArguments{bind(callee, first, second), bind(a, first, second), bind(b, first, second)}
    case R.InvokeWith{callee, value, updater}:
      R.InvokeWith{bind(callee, first, second), bind(value, first, second), updater}
    case R.Invoke{callee}:
      R.Invoke{bind(callee, first, second)}
    case R.OnCleanup{callee}:
      R.OnCleanup{bind(callee, first, second)}
    case R.WatchExpr{awaiter, body}:
      R.WatchExpr{awaiter, bind(body, first, second)}
    case R.Then{left, right}:
      R.Then{bind(left, first, second), bind(right, first, second)}
    case other:
      other
