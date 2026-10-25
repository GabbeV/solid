# Exact successful completion of the source no-subscriber settlement segment.
# Initial health and empty subscriber head are input facts, not an assumed
# transition result. Caller work, including a flush, is retained at the end.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/pending.bend as Q
import ../runtime/pending-state.bend as P
import ./owner-continuation.bend as Owner
import ./pending-continuation.bend as Pending
import ./pending-removal-footprint.bend as Removal
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver
import ./committed-storage-frame.bend as Committed
import ./pending-source-committed-frame.bend as SourceFrame

def after(+w: R.World, +id: Nat) -> R.World:
  B.first(R.World, Bool, P.removePendingSource(w, id, id))

def start(w: R.World, id: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  C.Machine{w, C.AsyncWriteAfterTrim{id} <> C.AsyncWriteSchedule{} <> rest, stack}

def walking(w: R.World, +id: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  C.Machine{w, C.PendingTasks{[Q.Walk{0n, id, id}, Q.Release{0n}, Q.End{}], [], [], False{}} <> C.AsyncWriteSchedule{} <> rest, stack}

def releasing(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  C.Machine{w, C.PendingTasks{[Q.Release{0n}, Q.End{}], [], [], False{}} <> C.AsyncWriteSchedule{} <> rest, stack}

def ending(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  C.Machine{w, C.PendingTasks{[Q.End{}], [], [], False{}} <> C.AsyncWriteSchedule{} <> rest, stack}

def returning(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  C.Machine{w, C.PendingTasks{[], [], [], False{}} <> C.AsyncWriteSchedule{} <> rest, stack}

def scheduling(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack}

def removedHealthy(+w: R.World, +id: Nat, healthy: {B.ok(w) == True{} : Bool}) ->
  {B.ok(after(w, id)) == True{} : Bool}:
  Equal.trans(Bool, B.ok(after(w, id)), B.ok(w), True{}, Removal.health(w, id, id), healthy)

def begins(+w: R.World, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.step(start(w, id, rest, stack)) == walking(after(w, id), id, rest, stack) : C.Machine}:
  +next = after(w, id)
  +empty = Equal.trans(Nat, R.Node.subs(B.node(next, id)), R.Node.subs(B.node(w, id)), 0n, Equal.cong(R.Node, Nat, node => R.Node.subs(node), B.node(next, id), B.node(w, id), Removal.node(w, id, id, id)), noSubscribers)
  Equal.trans(C.Machine, C.step(start(w, id, rest, stack)), C.dispatch(w, C.AsyncWriteAfterTrim{id} <> C.AsyncWriteSchedule{} <> rest, stack), walking(next, id, rest, stack),
    Owner.healthyStep(w, C.AsyncWriteAfterTrim{id}, C.AsyncWriteSchedule{} <> rest, stack, healthy),
    Equal.cong(Nat, C.Machine, edge => C.Machine{next, C.PendingTasks{[Q.Walk{edge, id, id}, Q.Release{0n}, Q.End{}], [], [], False{}} <> C.AsyncWriteSchedule{} <> rest, stack}, R.Node.subs(B.node(next, id)), 0n, empty))

def walkZero(+w: R.World, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.step(walking(w, id, rest, stack)) == releasing(w, rest, stack) : C.Machine}:
  Equal.trans(C.Machine, C.step(walking(w, id, rest, stack)), C.dispatch(w, C.PendingTasks{[Q.Walk{0n, id, id}, Q.Release{0n}, Q.End{}], [], [], False{}} <> C.AsyncWriteSchedule{} <> rest, stack), releasing(w, rest, stack), Owner.healthyStep(w, C.PendingTasks{[Q.Walk{0n, id, id}, Q.Release{0n}, Q.End{}], [], [], False{}}, C.AsyncWriteSchedule{} <> rest, stack, healthy), {==})

def releaseEmpty(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.step(releasing(w, rest, stack)) == ending(w, rest, stack) : C.Machine}:
  Equal.trans(C.Machine, C.step(releasing(w, rest, stack)), C.dispatch(w, C.PendingTasks{[Q.Release{0n}, Q.End{}], [], [], False{}} <> C.AsyncWriteSchedule{} <> rest, stack), ending(w, rest, stack), Owner.healthyStep(w, C.PendingTasks{[Q.Release{0n}, Q.End{}], [], [], False{}}, C.AsyncWriteSchedule{} <> rest, stack, healthy), {==})

def endQuiet(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.step(ending(w, rest, stack)) == returning(w, rest, stack) : C.Machine}:
  Equal.trans(C.Machine, C.step(ending(w, rest, stack)), C.dispatch(w, C.PendingTasks{[Q.End{}], [], [], False{}} <> C.AsyncWriteSchedule{} <> rest, stack), returning(w, rest, stack), Owner.healthyStep(w, C.PendingTasks{[Q.End{}], [], [], False{}}, C.AsyncWriteSchedule{} <> rest, stack, healthy), {==})

def returnCaller(w: R.World, +rest: List<&2, C.Task>, stack: List<&2, R.Value>) ->
  {C.step(returning(w, rest, stack)) == scheduling(w, rest, stack) : C.Machine}:
  Pending.emptyExact(w, C.AsyncWriteSchedule{} <> rest, stack, [], [], False{})

def schedules(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.step(scheduling(w, rest, stack)) == C.Machine{B.schedule(w), rest, stack} : C.Machine}:
  Equal.trans(C.Machine, C.step(scheduling(w, rest, stack)), C.dispatch(w, C.AsyncWriteSchedule{} <> rest, stack), C.Machine{B.schedule(w), rest, stack}, Owner.healthyStep(w, C.AsyncWriteSchedule{}, rest, stack, healthy), {==})

def exact(+w: R.World, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, +healthy: {B.ok(w) == True{} : Bool}) ->
  {Steps.iterate(6n, start(w, id, rest, stack)) == C.Machine{B.schedule(after(w, id)), rest, stack} : C.Machine}:
  +next = after(w, id)
  +ready = removedHealthy(w, id, healthy)
  +initial = start(w, id, rest, stack)
  +first = begins(w, id, rest, stack, noSubscribers, healthy)
  +second = Driver.appendStep(1n, initial, walking(next, id, rest, stack), releasing(next, rest, stack), first, walkZero(next, id, rest, stack, ready))
  +third = Driver.appendStep(2n, initial, releasing(next, rest, stack), ending(next, rest, stack), second, releaseEmpty(next, rest, stack, ready))
  +fourth = Driver.appendStep(3n, initial, ending(next, rest, stack), returning(next, rest, stack), third, endQuiet(next, rest, stack, ready))
  +fifth = Driver.appendStep(4n, initial, returning(next, rest, stack), scheduling(next, rest, stack), fourth, returnCaller(next, rest, stack))
  Driver.appendStep(5n, initial, scheduling(next, rest, stack), C.Machine{B.schedule(next), rest, stack}, fifth, schedules(next, rest, stack, ready))

# Actual Core.run can be split at this completed segment with its remaining
# fuel unchanged. Remaining zero still takes the source exhaustion policy.
def runBoundary(+w: R.World, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +remaining: Nat,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.run(Nat.add(6n, remaining), start(w, id, rest, stack)) == C.run(remaining, C.Machine{B.schedule(after(w, id)), rest, stack}) : C.Machine}:
  Equal.trans(C.Machine, C.run(Nat.add(6n, remaining), start(w, id, rest, stack)), C.run(remaining, Steps.iterate(6n, start(w, id, rest, stack))), C.run(remaining, C.Machine{B.schedule(after(w, id)), rest, stack}), Driver.split(6n, remaining, start(w, id, rest, stack)), Equal.cong(C.Machine, C.Machine, machine => C.run(remaining, machine), Steps.iterate(6n, start(w, id, rest, stack)), C.Machine{B.schedule(after(w, id)), rest, stack}, exact(w, id, rest, stack, noSubscribers, healthy)))

def committed(+w: R.World, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, healthy: {B.ok(w) == True{} : Bool}) ->
  {Committed.observe(C.world(Steps.iterate(6n, start(w, id, rest, stack)))) == Committed.observe(w) : Committed.View}:
  +next = after(w, id)
  Equal.trans(Committed.View, Committed.observe(C.world(Steps.iterate(6n, start(w, id, rest, stack)))), Committed.observe(B.schedule(next)), Committed.observe(w), Equal.cong(C.Machine, Committed.View, machine => Committed.observe(C.world(machine)), Steps.iterate(6n, start(w, id, rest, stack)), C.Machine{B.schedule(next), rest, stack}, exact(w, id, rest, stack, noSubscribers, healthy)), Committed.compose(w, next, B.schedule(next), Committed.schedule(next), SourceFrame.remove(w, id, id)))

def healthyResult(+w: R.World, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, +healthy: {B.ok(w) == True{} : Bool}) ->
  {B.ok(C.world(Steps.iterate(6n, start(w, id, rest, stack)))) == True{} : Bool}:
  +next = after(w, id)
  Equal.trans(Bool, B.ok(C.world(Steps.iterate(6n, start(w, id, rest, stack)))), B.ok(B.schedule(next)), True{}, Equal.cong(C.Machine, Bool, machine => B.ok(C.world(machine)), Steps.iterate(6n, start(w, id, rest, stack)), C.Machine{B.schedule(next), rest, stack}, exact(w, id, rest, stack, noSubscribers, healthy)), Equal.trans(Bool, B.ok(B.schedule(next)), B.ok(next), True{}, Removal.scheduleHealth(next), removedHealthy(w, id, healthy)))

# Construction of a six-step permitted prefix from the input metadata. Each
# later machine layout is derived from its actual transition; no transition
# result, stack equation or stable intermediate health premise is supplied.
def programme(+w: R.World, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, +healthy: {B.ok(w) == True{} : Bool}) -> Steps.Programme<start(w, id, rest, stack)>:
  +next = after(w, id)
  +ready = removedHealthy(w, id, healthy)
  +initial = start(w, id, rest, stack)
  +first = begins(w, id, rest, stack, noSubscribers, healthy)
  +second = Driver.appendStep(1n, initial, walking(next, id, rest, stack), releasing(next, rest, stack), first, walkZero(next, id, rest, stack, ready))
  +third = Driver.appendStep(2n, initial, releasing(next, rest, stack), ending(next, rest, stack), second, releaseEmpty(next, rest, stack, ready))
  +fourth = Driver.appendStep(3n, initial, ending(next, rest, stack), returning(next, rest, stack), third, endQuiet(next, rest, stack, ready))
  +fifth = Driver.appendStep(4n, initial, returning(next, rest, stack), scheduling(next, rest, stack), fourth, returnCaller(next, rest, stack))
  Steps.Step{w, C.AsyncWriteSchedule{} <> rest, stack, Steps.AfterTrim{id}, {==},
    Steps.Step{next, C.AsyncWriteSchedule{} <> rest, stack, Steps.Pending{[Q.Walk{0n, id, id}, Q.Release{0n}, Q.End{}], [], [], False{}}, first,
      Steps.Step{next, C.AsyncWriteSchedule{} <> rest, stack, Steps.Pending{[Q.Release{0n}, Q.End{}], [], [], False{}}, second,
        Steps.Step{next, C.AsyncWriteSchedule{} <> rest, stack, Steps.Pending{[Q.End{}], [], [], False{}}, third,
          Steps.Step{next, C.AsyncWriteSchedule{} <> rest, stack, Steps.Pending{[], [], [], False{}}, fourth,
            Steps.Step{next, rest, stack, Steps.Schedule{}, fifth, Steps.End{}}}}}}}

def programmeHeight(w: R.World, id: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, healthy: {B.ok(w) == True{} : Bool}) ->
  {Steps.height(start(w, id, rest, stack), programme(w, id, rest, stack, noSubscribers, healthy)) == 6n : Nat}:
  {==}
