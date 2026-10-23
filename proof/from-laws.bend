# Local closure/Promise laws of the source-following from(fn) branch. They
# quantify over arbitrary surrounding Worlds; no async-progress claim is made.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/from-state.bend as F
import ../runtime/promise-input.bend as P
import ../runtime/core.bend as C

# Proof-only expansions expose the selected source guard without changing the
# runtime's order, state updates or Promise behavior.
def settleSelected(+w: R.World, +plan: Nat, flag: Bool) -> R.World:
  +s = F.subscription(w, plan)
  +waiting = R.FromSubscription.waiting(s)
  B.choose(~R.World, flag, _ => w,
    _ => B.choose(~R.World, R.FromSubscription.has(s),
      _ => P.settle(F.store(w, plan, R.FromSubscription.with_has(R.FromSubscription.with_waiting(s, 0n), False{})), waiting, False{}, R.StepResult{False{}, R.FromSubscription.latest(s)}),
      _ => B.choose(~R.World, R.FromSubscription.failed(s),
        _ => P.settle(F.store(w, plan, R.FromSubscription.with_failed(R.FromSubscription.with_waiting(s, 0n), False{})), waiting, True{}, R.FromSubscription.failure(s)),
        _ => B.choose(~R.World, R.FromSubscription.done(s),
          _ => P.settle(F.store(w, plan, R.FromSubscription.with_waiting(s, 0n)), waiting, False{}, R.StepResult{True{}, R.Undefined{}}), _ => w))))

def settleNoWait(+w: R.World, +plan: Nat, known: {R.FromSubscription.waiting(F.subscription(w, plan)) == 0n : Nat}) ->
  {F.settle(w, plan) == w : R.World}:
  Equal.cong(Nat, R.World, waiting => settleSelected(w, plan, Nat.is_eq(waiting, 0n)), R.FromSubscription.waiting(F.subscription(w, plan)), 0n, known)

def emittedDone(+w: R.World, +plan: Nat, +value: R.Value, known: {R.FromSubscription.done(F.subscription(w, plan)) == True{} : Bool}) ->
  {F.emitted(w, plan, value) == w : R.World}:
  Equal.cong(Bool, R.World, done => B.choose(~R.World, done, _ => w, _ => F.settle(F.store(w, plan, R.FromSubscription.with_has(R.FromSubscription.with_latest(F.subscription(w, plan), value), True{})), plan)), R.FromSubscription.done(F.subscription(w, plan)), True{}, known)

def closeSelected(+w: R.World, +plan: Nat, flag: Bool) -> B.Bundle<R.World, R.Value>:
  +s = F.subscription(w, plan)
  B.choose(~B.Bundle<R.World, R.Value>, flag, _ => B.Bundle{w, R.Null{}},
    _ => B.Bundle{F.store(w, plan, R.FromSubscription.with_unsubscribe(R.FromSubscription.with_done(R.FromSubscription.with_closed(s, True{}), True{}), R.Null{})), R.FromSubscription.unsubscribe(s)})

def closedNoop(+w: R.World, +plan: Nat, known: {R.FromSubscription.closed(F.subscription(w, plan)) == True{} : Bool}) ->
  {F.close(w, plan) == B.Bundle{w, R.Null{}} : B.Bundle<R.World, R.Value>}:
  Equal.cong(Bool, B.Bundle<R.World, R.Value>, flag => closeSelected(w, plan, flag), R.FromSubscription.closed(F.subscription(w, plan)), True{}, known)

def closeOpen(+w: R.World, +plan: Nat, known: {R.FromSubscription.closed(F.subscription(w, plan)) == False{} : Bool}) ->
  {F.close(w, plan) == B.Bundle{F.store(w, plan, R.FromSubscription.with_unsubscribe(R.FromSubscription.with_done(R.FromSubscription.with_closed(F.subscription(w, plan), True{}), True{}), R.Null{})), R.FromSubscription.unsubscribe(F.subscription(w, plan))} : B.Bundle<R.World, R.Value>}:
  Equal.cong(Bool, B.Bundle<R.World, R.Value>, flag => closeSelected(w, plan, flag), R.FromSubscription.closed(F.subscription(w, plan)), False{}, known)

def finishSelected(+w: R.World, +plan: Nat, flag: Bool) -> R.World:
  +s = F.subscription(w, plan)
  +waiting = R.FromSubscription.waiting(s)
  +w = F.store(w, plan, R.FromSubscription.with_has(s, False{}))
  B.choose(~R.World, flag, _ => w,
    _ => P.settle(F.store(w, plan, R.FromSubscription.with_waiting(F.subscription(w, plan), 0n)), waiting, False{}, R.StepResult{True{}, R.Undefined{}}))

def finishNoWait(+w: R.World, +plan: Nat, known: {R.FromSubscription.waiting(F.subscription(w, plan)) == 0n : Nat}) ->
  {F.finish(w, plan) == F.store(w, plan, R.FromSubscription.with_has(F.subscription(w, plan), False{})) : R.World}:
  Equal.cong(Nat, R.World, waiting => finishSelected(w, plan, Nat.is_eq(waiting, 0n)), R.FromSubscription.waiting(F.subscription(w, plan)), 0n, known)

def allocateWorld(+w: R.World, +state: R.AsyncSettlement) ->
  {B.first(R.World, Nat, P.allocate(w, state)) == R.World.with_asyncObjects(w, B.append(R.AsyncObject, R.World.asyncObjects(w), [R.AsyncObject{False{}, state, [], 0n}])) : R.World}:
  {==}

def allocateIdentity(w: R.World, state: R.AsyncSettlement) ->
  {B.second(R.World, Nat, P.allocate(w, state)) == B.length(R.AsyncObject, R.World.asyncObjects(w)) : Nat}:
  {==}

def fulfilled(w: R.World, id: Nat, rejected: Bool, value: R.Value, object: R.AsyncObject, prior: R.Value) ->
  {P.settleState(w, id, rejected, value, object, R.Fulfilled{prior}) == w : R.World}:
  {==}

def rejected(w: R.World, id: Nat, rejected: Bool, value: R.Value, object: R.AsyncObject, prior: R.Value) ->
  {P.settleState(w, id, rejected, value, object, R.Rejected{prior}) == w : R.World}:
  {==}

def noObservers(w: R.World, rejected: Bool, value: R.Value) ->
  {P.deliveries([], w, rejected, value) == w : R.World}:
  {==}

def cleanupThrow(+w: R.World, rest: List<&2, C.Task>, saved: List<&2, R.Value>, cause: R.Value) ->
  {C.fromCleanupCatch(w, rest, saved, R.CallbackThrown{cause}) == C.Machine{R.World.with_fault(w, R.Healthy{}), rest, saved} : C.Machine}:
  {==}

def cleanupTypeError(+w: R.World, rest: List<&2, C.Task>, saved: List<&2, R.Value>) ->
  {C.fromCleanupCatch(w, rest, saved, R.TypeError{}) == C.Machine{R.World.with_fault(w, R.Healthy{}), rest, saved} : C.Machine}:
  {==}

def preserveExhaustion(w: R.World, rest: List<&2, C.Task>, saved: List<&2, R.Value>) ->
  {C.fromCleanupCatch(w, rest, saved, R.Exhausted{}) == C.Machine{w, rest, saved} : C.Machine}:
  {==}

def finished(+w: R.World, rest: List<&2, C.Task>, +stack: List<&2, R.Value>, plan: Nat) ->
  {C.dispatch(w, C.FromFinished{plan} <> rest, stack) == C.Machine{F.finish(w, plan), rest, R.StepResult{True{}, R.Undefined{}} <> stack} : C.Machine}:
  {==}
