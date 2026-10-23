# Typed protocol dispatch through nested from/deferred wrappers. The source
# method bodies remain in their original modules. Iterator references form an
# allocation-ordered DAG in this profile; its arena size bounds lookup depth.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./iterator-input.bend as Input
import ./deferred-stream.bend as Deferred
import ./from-wrap.bend as Wrapped
import ./from-state.bend as From
import ./promise-input.bend as P

def promised(pair: B.Bundle<R.World, Nat>) -> B.Bundle<R.World, R.NextInput>:
  match pair:
    case B.Bundle{w, id}: B.Bundle{w, R.PromiseNext{id}}

def nextDepth(depth: Nat, +w: R.World, +iterator: Nat, +argument: R.Slot) -> B.Bundle<R.World, R.NextInput>:
  match depth:
    case 0n: B.Bundle{R.World.with_fault(w, R.Unsupported{97n}), R.ThrowNext{R.Undefined{}}}
    case 1n+ +left:
      +plan = R.ExternalIterator.plan(B.iterator(w, iterator))
      +wrapper = R.StreamPlan.wrapper(B.streamPlan(w, plan))
      B.choose(~B.Bundle<R.World, R.NextInput>, Wrapped.isWrapped(w, iterator),
        _ => B.choose(~B.Bundle<R.World, R.NextInput>, R.FromWrapped.closed(Wrapped.get(w, plan)),
          _ => promised(P.allocate(w, R.Fulfilled{R.StepResult{True{}, R.Undefined{}}})),
          _ =>
            +pair = nextDepth(left, w, R.FromWrapped.inner(Wrapped.get(w, plan)), argument)
            Wrapped.wrapInput(B.first(R.World, R.NextInput, pair), plan, B.second(R.World, R.NextInput, pair))),
        _ => B.choose(~B.Bundle<R.World, R.NextInput>, Nat.is_ne(wrapper, 0n),
          _ =>
            +pair = nextDepth(left, w, R.DeferredIterator.inner(Deferred.wrapper(w, wrapper)), R.Present{R.Undefined{}})
            Deferred.afterNext(B.first(R.World, R.NextInput, pair), wrapper, B.second(R.World, R.NextInput, pair)),
          _ => Input.next(w, iterator, argument)))

def next(+w: R.World, iterator: Nat, argument: R.Slot) -> B.Bundle<R.World, R.NextInput>:
  nextDepth(1n+B.length(R.ExternalIterator, R.World.iterators(w)), w, iterator, argument)

def needsCoreDepth(depth: Nat, +w: R.World, +iterator: Nat) -> Bool:
  match depth:
    case 0n: False{}
    case 1n+ +left:
      +wrapper = R.StreamPlan.wrapper(B.streamPlan(w, R.ExternalIterator.plan(B.iterator(w, iterator))))
      B.choose(~Bool, Bool.or(From.isSubscription(w, iterator), Wrapped.isWrapped(w, iterator)), _ => True{},
        _ => B.choose(~Bool, Nat.is_eq(wrapper, 0n), _ => False{},
          _ => needsCoreDepth(left, w, R.DeferredIterator.inner(Deferred.wrapper(w, wrapper)))))

def needsCore(+w: R.World, iterator: Nat) -> Bool:
  needsCoreDepth(1n+B.length(R.ExternalIterator, R.World.iterators(w)), w, iterator)
