# deferred.ts:createDeferred's open-window iterator wrapper. The external
# iterator, wrapper identity and captured first flag stay distinct from the
# core async consumer. The existing iterator engine consumes the returned
# iterable; this module neither drains it nor publishes its yielded values.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./deferred-runtime.bend as D
import ./iterator-input.bend as Input

def wrapper(w: R.World, id: Nat) -> R.DeferredIterator:
  B.get(R.DeferredIterator, R.DeferredArena.iterators(R.World.deferredArena(w)), id, R.DeferredIterator{0n, 0n, 0n, False{}})

def store(+w: R.World, id: Nat, state: R.DeferredIterator) -> R.World:
  +arena = R.World.deferredArena(w)
  R.World.with_deferredArena(w, R.DeferredArena.with_iterators(arena, List.set(&2, R.DeferredIterator, R.DeferredArena.iterators(arena), id, state)))

def planWrapper(+w: R.World, source: Nat) -> Nat:
  R.StreamPlan.wrapper(B.streamPlan(w, R.AsyncObject.stream(B.asyncObject(w, source))))

# iterate.call(r), followed by first=true, s's allocation and the iterable
# that always returns that same s. Only the producer call records external IO.
def allocate(+w: R.World, cell: Nat, inner: Nat) -> B.Bundle<R.World, Nat>:
  +arena = R.World.deferredArena(w)
  +id = B.length(R.DeferredIterator, R.DeferredArena.iterators(arena))
  +iterator = B.length(R.ExternalIterator, R.World.iterators(w))
  +plan = B.length(R.StreamPlan, R.World.streamPlans(w))
  +object = B.length(R.AsyncObject, R.World.asyncObjects(w))
  +w = R.World.with_deferredArena(w, R.DeferredArena.with_iterators(arena, B.append(R.DeferredIterator, R.DeferredArena.iterators(arena), [R.DeferredIterator{cell, inner, iterator, True{}}])))
  +w = R.World.with_streamPlans(w, B.append(R.StreamPlan, R.World.streamPlans(w), [R.StreamPlan{[], True{}, R.Empty{}, 0n, id, R.Empty{}, R.FromNone{}}]))
  +w = R.World.with_iterators(w, B.append(R.ExternalIterator, R.World.iterators(w), [R.ExternalIterator{plan, 0n, 0n}]))
  B.Bundle{R.World.with_asyncObjects(w, B.append(R.AsyncObject, R.World.asyncObjects(w), [R.AsyncObject{False{}, R.Unresolved{}, [], plan}])), object}

def wrap(+w: R.World, +cell: Nat, source: Nat) -> B.Bundle<R.World, Nat>:
  +opened = Input.open(w, source)
  +w = B.first(R.World, Nat, opened)
  B.choose(~B.Bundle<R.World, Nat>, B.ok(w),
    _ => allocate(w, cell, B.second(R.World, Nat, opened)), _ => B.Bundle{w, 0n})

def flight(+w: R.World, object: Nat) -> R.Value:
  R.IteratorReference{R.DeferredIterator.iterator(wrapper(w, planWrapper(w, object)))}

def iterator(+w: R.World, source: Nat) -> Nat:
  R.DeferredIterator.iterator(wrapper(w, planWrapper(w, source)))

# This is p.then(done,done), before the async engine's own observer. Its
# callback lands the wrapper s, not the step promise or returned iterable.
def observeState(+w: R.World, +id: Nat, +observer: Nat, immediate: Bool, state: R.AsyncSettlement) -> R.World:
  match state:
    case R.Unresolved{}: w
    case R.Fulfilled{+value}:
      B.choose(~R.World, immediate,
        _ => D.land(w, R.DeferredIterator.cell(wrapper(w, id)), R.IteratorReference{R.DeferredIterator.iterator(wrapper(w, id))}, True{}),
        _ => R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.DeliveryJob{observer, False{}, value}])))
    case R.Rejected{+error}:
      B.choose(~R.World, immediate,
        _ => D.land(w, R.DeferredIterator.cell(wrapper(w, id)), R.IteratorReference{R.DeferredIterator.iterator(wrapper(w, id))}, True{}),
        _ => R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.DeliveryJob{observer, True{}, error}])))

def observe(+w: R.World, +id: Nat, +result: Nat) -> R.World:
  +observer = B.length(R.AsyncObserver, R.World.asyncObservers(w))
  +w = R.World.with_asyncObservers(w, B.append(R.AsyncObserver, R.World.asyncObservers(w), [R.AsyncObserver{0n, result, True{}, False{}, False{}, R.Undefined{}, R.Undefined{}, 0n, 0n}]))
  +w = D.registerWait(w, observer, R.DeferredIterator.cell(wrapper(w, id)), R.IteratorReference{R.DeferredIterator.iterator(wrapper(w, id))})
  +object = B.asyncObject(w, result)
  +w = B.store_asyncObject(w, result, R.AsyncObject.with_observers(object, B.append(Nat, R.AsyncObject.observers(object), [observer])))
  observeState(w, id, observer, R.AsyncObject.immediate(object), R.AsyncObject.state(object))

def firstInput(+w: R.World, +id: Nat, input: R.NextInput) -> B.Bundle<R.World, R.NextInput>:
  match input:
    # it.next threw before reaching the source's first=false assignment.
    case R.ThrowNext{error}: B.Bundle{w, R.ThrowNext{error}}
    case R.BareNext{done, value}:
      +s = wrapper(w, id)
      +w = store(w, id, R.DeferredIterator.with_first(s, False{}))
      B.Bundle{D.land(w, R.DeferredIterator.cell(s), R.IteratorReference{R.DeferredIterator.iterator(s)}, True{}), R.BareNext{done, value}}
    case R.PromiseNext{+result}:
      +w = store(w, id, R.DeferredIterator.with_first(wrapper(w, id), False{}))
      B.Bundle{observe(w, id, result), R.PromiseNext{result}}

def afterNext(+w: R.World, +id: Nat, +input: R.NextInput) -> B.Bundle<R.World, R.NextInput>:
  B.choose(~B.Bundle<R.World, R.NextInput>, R.DeferredIterator.first(wrapper(w, id)),
    _ => firstInput(w, id, input), _ => B.Bundle{w, input})

def next(+w: R.World, +id: Nat) -> B.Bundle<R.World, R.NextInput>:
  +pair = Input.next(w, R.DeferredIterator.inner(wrapper(w, id)), R.Present{R.Undefined{}})
  afterNext(B.first(R.World, R.NextInput, pair), id, B.second(R.World, R.NextInput, pair))

# The wrapper always has return(). Missing inner return falls back to the
# source's Promise.resolve(DONE); existing return errors pass to close's catch.
def resolvedDone(+w: R.World) -> B.Bundle<R.World, Input.Returned>:
  +result = B.length(R.AsyncObject, R.World.asyncObjects(w))
  B.Bundle{R.World.with_asyncObjects(w, B.append(R.AsyncObject, R.World.asyncObjects(w), [R.AsyncObject{False{}, R.Fulfilled{R.StepResult{True{}, R.Undefined{}}}, [], 0n}])), Input.PromiseReturn{result}}

def returnInput(+w: R.World, returned: Input.Returned) -> B.Bundle<R.World, Input.Returned>:
  match returned:
    case Input.MissingReturn{}: resolvedDone(w)
    case Input.RawReturn{+value}:
      B.choose(~B.Bundle<R.World, Input.Returned>, B.nullish(value),
        _ => resolvedDone(w), _ => B.Bundle{w, Input.RawReturn{value}})
    case other: B.Bundle{w, other}

def returned(+w: R.World, id: Nat) -> B.Bundle<R.World, Input.Returned>:
  +pair = Input.returned(w, R.DeferredIterator.inner(wrapper(w, id)), R.Present{R.Undefined{}})
  returnInput(B.first(R.World, Input.Returned, pair), B.second(R.World, Input.Returned, pair))
