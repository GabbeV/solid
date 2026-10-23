# from.ts subscription closures. Producer callbacks and cleanup invocation run
# through Core; this module stores closure state and native Promise inputs.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./promise-input.bend as Promise

def origin(+w: R.World, source: Nat) -> R.FromState:
  R.StreamPlan.fromState(B.streamPlan(w, R.AsyncObject.stream(B.asyncObject(w, source))))

def factoryState(state: R.FromState) -> Bool:
  match state:
    case R.FromFunction{callee}: True{}
    case R.FromIterable{source}: True{}
    case _: False{}

def factory(w: R.World, source: Nat) -> Bool:
  factoryState(origin(w, source))

def create(+w: R.World, state: R.FromState) -> B.Bundle<R.World, Nat>:
  +plan = B.length(R.StreamPlan, R.World.streamPlans(w))
  +object = B.length(R.AsyncObject, R.World.asyncObjects(w))
  +w = R.World.with_streamPlans(w, B.append(R.StreamPlan, R.World.streamPlans(w), [R.StreamPlan{[], True{}, R.Empty{}, 0n, 0n, R.Empty{}, state}]))
  B.Bundle{R.World.with_asyncObjects(w, B.append(R.AsyncObject, R.World.asyncObjects(w), [R.AsyncObject{False{}, R.Unresolved{}, [], plan}])), object}

def callable(value: R.Value) -> Bool:
  match value:
    case R.ProgramReference{callback}: True{}
    case R.AccessorReference{signal}: True{}
    case R.SetterReference{signal}: True{}
    case R.RootDisposerReference{owner}: True{}
    case _: False{}

def empty() -> R.FromSubscription:
  R.FromSubscription{R.Undefined{}, False{}, False{}, False{}, R.Undefined{}, 0n, R.Null{}, False{}, 0n}

def subscriptionState(state: R.FromState) -> R.FromSubscription:
  match state:
    case R.FromSubscriptionState{subscription}: subscription
    case _: empty()

def subscription(w: R.World, plan: Nat) -> R.FromSubscription:
  subscriptionState(R.StreamPlan.fromState(B.streamPlan(w, plan)))

def store(+w: R.World, +plan: Nat, state: R.FromSubscription) -> R.World:
  +plans = R.World.streamPlans(w)
  R.World.with_streamPlans(w, List.set(&2, R.StreamPlan, plans, plan, R.StreamPlan.with_fromState(B.streamPlan(w, plan), R.FromSubscriptionState{state})))

def isSubscriptionState(state: R.FromState) -> Bool:
  match state:
    case R.FromSubscriptionState{subscription}: True{}
    case _: False{}

def isSubscription(+w: R.World, iterator: Nat) -> Bool:
  isSubscriptionState(R.StreamPlan.fromState(B.streamPlan(w, R.ExternalIterator.plan(B.iterator(w, iterator)))))

type Opened is Data:
  Opened{world: R.World, iterator: Nat, callee: R.Value, next: Nat, error: Nat, complete: Nat}

def open(+w: R.World, callee: R.Value) -> Opened:
  +plan = B.length(R.StreamPlan, R.World.streamPlans(w))
  +iterator = B.length(R.ExternalIterator, R.World.iterators(w))
  +callback = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
  +w = R.World.with_streamPlans(w, B.append(R.StreamPlan, R.World.streamPlans(w), [R.StreamPlan{[], True{}, R.Empty{}, 0n, 0n, R.Empty{}, R.FromSubscriptionState{empty()}}]))
  +w = R.World.with_iterators(w, B.append(R.ExternalIterator, R.World.iterators(w), [R.ExternalIterator{plan, 0n, 0n}]))
  +w = R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.FromNext{plan}], False{}, 1n}, R.CleanupProgram{[R.FromError{plan}], False{}, 1n}, R.CleanupProgram{[R.FromComplete{plan}], False{}, 0n}]))
  Opened{w, iterator, callee, callback, 1n+callback, 2n+callback}

def settle(+w: R.World, +plan: Nat) -> R.World:
  +s = subscription(w, plan)
  +waiting = R.FromSubscription.waiting(s)
  B.choose(~R.World, Nat.is_eq(waiting, 0n), _ => w,
    _ => B.choose(~R.World, R.FromSubscription.has(s),
      _ => Promise.settle(store(w, plan, R.FromSubscription.with_has(R.FromSubscription.with_waiting(s, 0n), False{})), waiting, False{}, R.StepResult{False{}, R.FromSubscription.latest(s)}),
      _ => B.choose(~R.World, R.FromSubscription.failed(s),
        _ => Promise.settle(store(w, plan, R.FromSubscription.with_failed(R.FromSubscription.with_waiting(s, 0n), False{})), waiting, True{}, R.FromSubscription.failure(s)),
        _ => B.choose(~R.World, R.FromSubscription.done(s),
          _ => Promise.settle(store(w, plan, R.FromSubscription.with_waiting(s, 0n)), waiting, False{}, R.StepResult{True{}, R.Undefined{}}), _ => w))))

def emitted(+w: R.World, +plan: Nat, value: R.Value) -> R.World:
  +s = subscription(w, plan)
  B.choose(~R.World, R.FromSubscription.done(s), _ => w,
    _ => settle(store(w, plan, R.FromSubscription.with_has(R.FromSubscription.with_latest(s, value), True{})), plan))

# The Core caller tests done before setting it, then runs close after settle.
def failed(+w: R.World, +plan: Nat, error: R.Value) -> R.World:
  +s = subscription(w, plan)
  settle(store(w, plan, R.FromSubscription.with_done(R.FromSubscription.with_failure(R.FromSubscription.with_failed(s, True{}), error), True{})), plan)

def completed(+w: R.World, +plan: Nat) -> R.World:
  settle(store(w, plan, R.FromSubscription.with_done(subscription(w, plan), True{})), plan)

def close(+w: R.World, +plan: Nat) -> B.Bundle<R.World, R.Value>:
  +s = subscription(w, plan)
  B.choose(~B.Bundle<R.World, R.Value>, R.FromSubscription.closed(s), _ => B.Bundle{w, R.Null{}},
    _ => B.Bundle{store(w, plan, R.FromSubscription.with_unsubscribe(R.FromSubscription.with_done(R.FromSubscription.with_closed(s, True{}), True{}), R.Null{})), R.FromSubscription.unsubscribe(s)})

def finish(+w: R.World, +plan: Nat) -> R.World:
  +s = subscription(w, plan)
  +waiting = R.FromSubscription.waiting(s)
  +w = store(w, plan, R.FromSubscription.with_has(s, False{}))
  B.choose(~R.World, Nat.is_eq(waiting, 0n), _ => w,
    _ => Promise.settle(store(w, plan, R.FromSubscription.with_waiting(subscription(w, plan), 0n)), waiting, False{}, R.StepResult{True{}, R.Undefined{}}))

def promised(pair: B.Bundle<R.World, Nat>) -> B.Bundle<R.World, R.NextInput>:
  match pair:
    case B.Bundle{w, result}: B.Bundle{w, R.PromiseNext{result}}

def next(+w: R.World, +plan: Nat) -> B.Bundle<R.World, R.NextInput>:
  +s = subscription(w, plan)
  B.choose(~B.Bundle<R.World, R.NextInput>, R.FromSubscription.has(s),
    _ => B.Bundle{store(w, plan, R.FromSubscription.with_has(s, False{})), R.BareNext{False{}, R.FromSubscription.latest(s)}},
    _ => B.choose(~B.Bundle<R.World, R.NextInput>, R.FromSubscription.failed(s),
      _ => promised(Promise.allocate(store(w, plan, R.FromSubscription.with_failed(s, False{})), R.Rejected{R.FromSubscription.failure(s)})),
      _ => B.choose(~B.Bundle<R.World, R.NextInput>, R.FromSubscription.done(s),
        _ => promised(Promise.allocate(w, R.Fulfilled{R.StepResult{True{}, R.Undefined{}}})),
        _ =>
          +pair = Promise.allocate(w, R.Unresolved{})
          +w = B.first(R.World, Nat, pair)
          +result = B.second(R.World, Nat, pair)
          B.Bundle{store(w, plan, R.FromSubscription.with_waiting(s, result)), R.PromiseNext{result}})))
