# from.ts:wrapIterable closure state. Pull/return method invocation is provided
# by IteratorMethods/Core; this module retains pending resolve identities and
# the callbacks installed by step.then, without reactive publication.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./promise-input.bend as P

def wrappedState(state: R.FromState) -> Bool:
  match state:
    case R.FromWrappedState{state}: True{}
    case _: False{}

def isWrapped(+w: R.World, iterator: Nat) -> Bool:
  wrappedState(R.StreamPlan.fromState(B.streamPlan(w, R.ExternalIterator.plan(B.iterator(w, iterator)))))

def stateValue(state: R.FromState) -> R.FromWrapped:
  match state:
    case R.FromWrappedState{state}: state
    case _: R.FromWrapped{0n, False{}, [], [], 0n}

def get(+w: R.World, plan: Nat) -> R.FromWrapped:
  stateValue(R.StreamPlan.fromState(B.streamPlan(w, plan)))

def store(+w: R.World, +plan: Nat, state: R.FromWrapped) -> R.World:
  R.World.with_streamPlans(w, List.set(&2, R.StreamPlan, R.World.streamPlans(w), plan, R.StreamPlan.with_fromState(B.streamPlan(w, plan), R.FromWrappedState{state})))

def allocate(+w: R.World, inner: Nat) -> B.Bundle<R.World, Nat>:
  +plan = B.length(R.StreamPlan, R.World.streamPlans(w))
  +iterator = B.length(R.ExternalIterator, R.World.iterators(w))
  +w = R.World.with_streamPlans(w, B.append(R.StreamPlan, R.World.streamPlans(w), [R.StreamPlan{[], True{}, R.Empty{}, 0n, 0n, R.Empty{}, R.FromWrappedState{R.FromWrapped{inner, False{}, [], [], 0n}}}]))
  B.Bundle{R.World.with_iterators(w, B.append(R.ExternalIterator, R.World.iterators(w), [R.ExternalIterator{plan, 0n, 0n}])), iterator}

def has(items: List<&2, Nat>, +id: Nat) -> Bool:
  match items:
    case Nil{}: False{}
    case head <> tail: Bool.or(Nat.is_eq(head, id), has(tail, id))

def remove(items: List<&2, Nat>, +id: Nat) -> List<&2, Nat>:
  match items:
    case Nil{}: []
    case +head <> +tail:
      B.choose(~List<&2, Nat>, Nat.is_eq(head, id), _ => tail, _ => head <> remove(tail, id))

def resolvePending(items: List<&2, Nat>, w: R.World) -> R.World:
  match items:
    case Nil{}: w
    case head <> tail: resolvePending(tail, P.settle(w, head, False{}, R.StepResult{True{}, R.Undefined{}}))

# finish sets closed before settling pending pulls; clear follows the resolve
# loop and precedes the captured inner return() call, supplied by Core.
def finish(+w: R.World, +plan: Nat) -> R.World:
  +s = get(w, plan)
  +w = store(w, plan, R.FromWrapped.with_closed(s, True{}))
  +w = resolvePending(R.FromWrapped.pending(s), w)
  store(w, plan, R.FromWrapped.with_pending(get(w, plan), []))

def deliver(+w: R.World, +plan: Nat, +output: Nat, rejected: Bool, value: R.Value) -> R.World:
  +s = get(w, plan)
  B.choose(~R.World, has(R.FromWrapped.pending(s), output),
    _ => P.settle(store(w, plan, R.FromWrapped.with_pending(s, remove(R.FromWrapped.pending(s), output))), output, rejected, value), _ => w)

def observerState(+w: R.World, +plan: Nat, +output: Nat, +observer: Nat, immediate: Bool, state: R.AsyncSettlement) -> R.World:
  match state:
    case R.Unresolved{}: w
    case R.Fulfilled{+value}:
      B.choose(~R.World, immediate, _ => deliver(w, plan, output, False{}, value),
        _ => R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.DeliveryJob{observer, False{}, value}])))
    case R.Rejected{+error}:
      B.choose(~R.World, immediate, _ => deliver(w, plan, output, True{}, error),
        _ => R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.DeliveryJob{observer, True{}, error}])))

def wrapInput(+w: R.World, +plan: Nat, input: R.NextInput) -> B.Bundle<R.World, R.NextInput>:
  match input:
    case R.PromiseNext{+result}:
      +allocated = P.allocate(w, R.Unresolved{})
      +w = B.first(R.World, Nat, allocated)
      +output = B.second(R.World, Nat, allocated)
      +observer = B.length(R.AsyncObserver, R.World.asyncObservers(w))
      +s = get(w, plan)
      +w = store(w, plan, R.FromWrapped.with_waits(R.FromWrapped.with_pending(s, B.append(Nat, R.FromWrapped.pending(s), [output])), B.append(R.FromWait, R.FromWrapped.waits(s), [R.FromWait{observer, output}])))
      +w = R.World.with_asyncObservers(w, B.append(R.AsyncObserver, R.World.asyncObservers(w), [R.AsyncObserver{0n, result, False{}, False{}, False{}, R.Undefined{}, R.Undefined{}, 0n, 0n}]))
      +object = B.asyncObject(w, result)
      +w = B.store_asyncObject(w, result, R.AsyncObject.with_observers(object, B.append(Nat, R.AsyncObject.observers(object), [observer])))
      B.Bundle{observerState(w, plan, output, observer, R.AsyncObject.immediate(object), R.AsyncObject.state(object)), R.PromiseNext{output}}
    case other: B.Bundle{w, other}

# The lookup retrieves the actual captured callback's plan/output identities.
# It is representation lookup, not a second delivery or scheduler algorithm.
def findWait(waits: List<&2, R.FromWait>, +observer: Nat) -> Nat:
  match waits:
    case Nil{}: 0n
    case +head <> tail: B.choose(~Nat, Nat.is_eq(R.FromWait.observer(head), observer), _ => R.FromWait.output(head), _ => findWait(tail, observer))

def findPlans(plans: List<&2, R.StreamPlan>, +observer: Nat, +id: Nat) -> B.Bundle<Nat, Nat>:
  match plans:
    case Nil{}: B.Bundle{0n, 0n}
    case head <> tail:
      +output = findWait(R.FromWrapped.waits(stateValue(R.StreamPlan.fromState(head))), observer)
      B.choose(~B.Bundle<Nat, Nat>, Nat.is_ne(output, 0n), _ => B.Bundle{id, output}, _ => findPlans(tail, observer, 1n+id))

def find(w: R.World, observer: Nat) -> B.Bundle<Nat, Nat>:
  findPlans(R.World.streamPlans(w), observer, 0n)
