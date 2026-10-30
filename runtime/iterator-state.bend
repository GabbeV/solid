# handleAsync's iterator closure state and typed external method protocol.
# Leaf module: owner cleanup can close a stream without importing core/flight.
import Base
import ./iterator-input.bend as Input
import ./iterator-methods.bend as Methods
import ./deferred-stream.bend as DeferredStream
import ../representation/records.bend as R
import ../representation/base.bend as B

def newIterableProtocol(+w: R.World, steps: List<&2, R.NextInput>, hasReturn: Bool, returnError: R.Slot, returnResult: Nat, factoryError: R.Slot) -> R.World:
  +plan = B.length(R.StreamPlan, R.World.streamPlans(w))
  +w = R.World.with_streamPlans(w, B.append(R.StreamPlan, R.World.streamPlans(w), [R.StreamPlan{steps, hasReturn, returnError, returnResult, 0n, factoryError, R.FromNone{}}]))
  R.World.with_asyncObjects(w, B.append(R.AsyncObject, R.World.asyncObjects(w), [R.AsyncObject{False{}, R.Unresolved{}, [], plan}]))

def newIterable(w: R.World, steps: List<&2, R.NextInput>, hasReturn: Bool, returnError: R.Slot, returnResult: Nat) -> R.World:
  newIterableProtocol(w, steps, hasReturn, returnError, returnResult, R.Empty{})

# source[Symbol.asyncIterator]() creates this external iterator. Its supplied
# next descriptors are host inputs. Every consumption gets its own cursor.
def streamForIterator(+w: R.World, node: Nat, result: Nat, iterator: Nat, deferred: Bool, initialValue: R.Value) -> B.Bundle<R.World, Nat>:
  +stream = B.length(R.StreamState, R.World.streams(w))
  +close = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
  +w = R.World.with_streams(w, B.append(R.StreamState, R.World.streams(w), [R.StreamState{node, result, iterator, False{}, False{}, Bool.not(deferred), initialValue, close}]))
  +w = R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.CleanupCloseIterator{stream}], False{}, 0n}]))
  B.Bundle{w, stream}

def newStream(+w: R.World, +node: Nat, +result: Nat, +source: Nat, +deferred: Bool, +initialValue: R.Value) -> B.Bundle<R.World, Nat>:
  +pair = B.choose(~B.Bundle<R.World, Nat>, Nat.is_ne(DeferredStream.planWrapper(w, source), 0n),
    _ => B.Bundle{w, DeferredStream.iterator(w, source)}, _ => Input.open(w, source))
  +w = B.first(R.World, Nat, pair)
  B.choose(~B.Bundle<R.World, Nat>, B.ok(w),
    _ => streamForIterator(w, node, result, B.second(R.World, Nat, pair), deferred, initialValue), _ => B.Bundle{w, 0n})

def next(+w: R.World, stream: Nat) -> B.Bundle<R.World, R.NextInput>:
  Methods.next(w, R.StreamState.iterator(B.stream(w, stream)), R.Empty{})

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
  +w = R.World.with_asyncObservers(w, B.append(R.AsyncObserver, R.World.asyncObservers(w), [R.AsyncObserver{0n, result, False{}, False{}, False{}, R.Undefined{}, R.Undefined{}, 0n, 0n}]))
  +object = B.asyncObject(w, result)
  +w = B.store_asyncObject(w, result, R.AsyncObject.with_observers(object, B.append(Nat, R.AsyncObject.observers(object), [observer])))
  ignoreState(w, observer, R.AsyncObject.immediate(object), R.AsyncObject.state(object))

# close marks completed before calling return; return/then throws and rejected
# returns are swallowed. The external descriptor has no arbitrary user callback.
def closeResult(w: R.World, returned: Input.Returned) -> R.World:
  match returned:
    case Input.PromiseReturn{result}: ignoreThen(w, result)
    case _: w

def close(+w: R.World, +stream: Nat) -> R.World:
  +state = B.stream(w, stream)
  B.choose(~R.World, R.StreamState.completed(state), _ => w,
    _ =>
      +w = B.store_stream(w, stream, R.StreamState.with_completed(state, True{}))
      +id = R.StreamState.iterator(state)
      +wrapper = R.StreamPlan.wrapper(B.streamPlan(w, R.ExternalIterator.plan(B.iterator(w, id))))
      +pair = B.choose(~B.Bundle<R.World, Input.Returned>, Nat.is_ne(wrapper, 0n),
        _ => DeferredStream.returned(w, wrapper), _ => Input.returned(w, id, R.Empty{}))
      closeResult(B.first(R.World, Input.Returned, pair), B.second(R.World, Input.Returned, pair)))

def newStepObserver(+w: R.World, +stream: Nat) -> B.Bundle<R.World, Nat>:
  +id = B.length(R.AsyncObserver, R.World.asyncObservers(w))
  +state = B.stream(w, stream)
  B.Bundle{R.World.with_asyncObservers(w, B.append(R.AsyncObserver, R.World.asyncObservers(w), [R.AsyncObserver{R.StreamState.node(state), R.StreamState.result(state), True{}, False{}, False{}, R.Undefined{}, R.Undefined{}, stream, 0n}])), id}
