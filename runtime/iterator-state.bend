# handleAsync's iterator closure state and typed external method protocol.
# Leaf module: owner cleanup can close a stream without importing core/flight.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def newIterable(+w: R.World, steps: List<&2, R.NextInput>, hasReturn: Bool, returnError: R.Slot, returnResult: Nat) -> R.World:
  +plan = B.length(R.StreamPlan, R.World.streamPlans(w))
  +w = R.World.with_streamPlans(w, B.append(R.StreamPlan, R.World.streamPlans(w), [R.StreamPlan{steps, hasReturn, returnError, returnResult}]))
  R.World.with_asyncObjects(w, B.append(R.AsyncObject, R.World.asyncObjects(w), [R.AsyncObject{False{}, R.Unresolved{}, [], plan}]))

# source[Symbol.asyncIterator]() creates this external iterator. Its supplied
# next descriptors are host inputs. Every consumption gets its own cursor.
def newStream(+w: R.World, +node: Nat, result: Nat, +source: Nat, deferred: Bool, initialValue: R.Value) -> B.Bundle<R.World, Nat>:
  +iterator = B.length(R.ExternalIterator, R.World.iterators(w))
  +stream = B.length(R.StreamState, R.World.streams(w))
  +close = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
  +w = R.World.with_iterators(w, B.append(R.ExternalIterator, R.World.iterators(w), [R.ExternalIterator{R.AsyncObject.stream(B.asyncObject(w, source)), 0n, 0n}]))
  +w = R.World.with_streams(w, B.append(R.StreamState, R.World.streams(w), [R.StreamState{node, result, iterator, False{}, False{}, Bool.not(deferred), initialValue, close}]))
  +w = R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.CleanupCloseIterator{stream}]}]))
  B.Bundle{B.iteratorEvent(w, R.IteratorStarted{source, iterator}), stream}

def next(+w: R.World, stream: Nat) -> B.Bundle<R.World, R.NextInput>:
  +id = R.StreamState.iterator(B.stream(w, stream))
  +it = B.iterator(w, id)
  +index = R.ExternalIterator.cursor(it)
  +w = B.store_iterator(w, id, R.ExternalIterator.with_cursor(it, 1n+index))
  B.Bundle{B.iteratorEvent(w, R.IteratorNext{id, index}), B.get(R.NextInput, R.StreamPlan.steps(B.streamPlan(w, R.ExternalIterator.plan(it))), index, R.BareNext{True{}, R.Undefined{}})}

# A returned thenable has only a rejection-swallow callback. Native-style
# completion is external IO; a node-zero observer is explicitly a no-op.
def ignoreState(+w: R.World, observer: Nat, immediate: Bool, state: R.AsyncSettlement) -> R.World:
  match state:
    case R.Unresolved{}:
      w
    case R.Fulfilled{value}:
      w
    case R.Rejected{error}:
      B.choose(~R.World, immediate, _ => w,
        _ => R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.DeliveryJob{observer, True{}, error}])))

def ignoreThen(+w: R.World, +result: Nat) -> R.World:
  +observer = B.length(R.AsyncObserver, R.World.asyncObservers(w))
  +w = R.World.with_asyncObservers(w, B.append(R.AsyncObserver, R.World.asyncObservers(w), [R.AsyncObserver{0n, result, False{}, False{}, False{}, R.Undefined{}, R.Undefined{}, 0n}]))
  +object = B.asyncObject(w, result)
  +w = B.store_asyncObject(w, result, R.AsyncObject.with_observers(object, B.append(Nat, R.AsyncObject.observers(object), [observer])))
  ignoreState(w, observer, R.AsyncObject.immediate(object), R.AsyncObject.state(object))

# close marks completed before calling return; return/then throws and rejected
# returns are swallowed. The external descriptor has no arbitrary user callback.
def close(+w: R.World, +stream: Nat) -> R.World:
  +state = B.stream(w, stream)
  B.choose(~R.World, R.StreamState.completed(state), _ => w,
    _ =>
      +w = B.store_stream(w, stream, R.StreamState.with_completed(state, True{}))
      +id = R.StreamState.iterator(state)
      +it = B.iterator(w, id)
      +plan = B.streamPlan(w, R.ExternalIterator.plan(it))
      B.choose(~R.World, R.StreamPlan.hasReturn(plan),
        _ =>
          +w = B.store_iterator(w, id, R.ExternalIterator.with_returns(it, 1n+R.ExternalIterator.returns(it)))
          +w = B.iteratorEvent(w, R.IteratorReturned{id})
          B.choose(~R.World, Bool.or(B.present(R.StreamPlan.returnError(plan)), Nat.is_eq(R.StreamPlan.returnResult(plan), 0n)), _ => w,
            _ => ignoreThen(w, R.StreamPlan.returnResult(plan))), _ => w))

def newStepObserver(+w: R.World, +stream: Nat) -> B.Bundle<R.World, Nat>:
  +id = B.length(R.AsyncObserver, R.World.asyncObservers(w))
  +state = B.stream(w, stream)
  B.Bundle{R.World.with_asyncObservers(w, B.append(R.AsyncObserver, R.World.asyncObservers(w), [R.AsyncObserver{R.StreamState.node(state), R.StreamState.result(state), True{}, False{}, False{}, R.Undefined{}, R.Undefined{}, stream}])), id}
