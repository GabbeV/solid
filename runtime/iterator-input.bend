# Typed external iterator method boundary. Descriptors are producer inputs,
# including protocol throws; no reactive publication decision is made here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

type Returned is Data:
  MissingReturn{}
  RawReturn{value: R.Value}
  PromiseReturn{result: Nat}
  ThrowReturn{error: R.Value}

def open(+w: R.World, +source: Nat) -> B.Bundle<R.World, Nat>:
  +failed = R.StreamPlan.factoryError(B.streamPlan(w, R.AsyncObject.stream(B.asyncObject(w, source))))
  B.choose(~B.Bundle<R.World, Nat>, B.present(failed),
    _ =>
      +error = B.selected(failed, R.Undefined{})
      B.Bundle{R.World.with_fault(B.iteratorEvent(w, R.IteratorFactoryFailed{source, error}), R.CallbackThrown{error}), 0n},
    _ =>
      +id = B.length(R.ExternalIterator, R.World.iterators(w))
      +w = R.World.with_iterators(w, B.append(R.ExternalIterator, R.World.iterators(w), [R.ExternalIterator{R.AsyncObject.stream(B.asyncObject(w, source)), 0n, 0n}]))
      B.Bundle{B.iteratorEvent(w, R.IteratorStarted{source, id}), id})

def next(+w: R.World, +id: Nat, argument: R.Slot) -> B.Bundle<R.World, R.NextInput>:
  +it = B.iterator(w, id)
  +index = R.ExternalIterator.cursor(it)
  +w = B.store_iterator(w, id, R.ExternalIterator.with_cursor(it, 1n+index))
  B.Bundle{B.iteratorEvent(w, R.IteratorNext{id, index, argument}), B.get(R.NextInput, R.StreamPlan.steps(B.streamPlan(w, R.ExternalIterator.plan(it))), index, R.BareNext{True{}, R.Undefined{}})}

def returned(+w: R.World, +id: Nat, argument: R.Slot) -> B.Bundle<R.World, Returned>:
  +it = B.iterator(w, id)
  +plan = B.streamPlan(w, R.ExternalIterator.plan(it))
  B.choose(~B.Bundle<R.World, Returned>, R.StreamPlan.hasReturn(plan),
    _ =>
      +w = B.store_iterator(w, id, R.ExternalIterator.with_returns(it, 1n+R.ExternalIterator.returns(it)))
      +w = B.iteratorEvent(w, R.IteratorReturned{id, argument})
      B.choose(~B.Bundle<R.World, Returned>, B.present(R.StreamPlan.returnError(plan)),
        _ => B.Bundle{w, ThrowReturn{B.selected(R.StreamPlan.returnError(plan), R.Undefined{})}},
        _ => B.choose(~B.Bundle<R.World, Returned>, Nat.is_eq(R.StreamPlan.returnResult(plan), 0n),
          _ => B.Bundle{w, RawReturn{R.Undefined{}}}, _ => B.Bundle{w, PromiseReturn{R.StreamPlan.returnResult(plan)}})),
    _ => B.Bundle{w, MissingReturn{}})
