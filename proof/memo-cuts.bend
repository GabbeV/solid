import Base
import ../runtime/equality.bend as EQ
import ../runtime/api.bend as A
import ../proof/paths.bend as P
import ../runtime/core.bend as C
import ../runtime/owner.bend as O
import ../runtime/pending.bend as Q
import ../runtime/constants.bend as K
import ../representation/base.bend as B
import ../representation/records.bend as R

# This fixed frame is the source scalar memo's completed first update.
def frame() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, R.Number{1n}, False{}, R.Number{0n}, 0n, False{}, R.FlightUndefined{}, [], 0n, False{}, C.LanePass{0n, R.MountUnset{}, R.MountFalse{}, False{}}}

def step_release(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value, ready: {B.ok(w) == True{} : Bool}) ->
  {C.step(C.Machine{w, C.PassReleases{frame(), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, stack})
    == C.passReleases(w, rest, stack, frame(), 0n, value, False{}, False{}, False{}, R.Healthy{}) : C.Machine}:
  +tasks = {C.PassReleases{frame(), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest : List<&2, C.Task>}
  Equal.cong(Bool, C.Machine, healthy => B.choose(~C.Machine, healthy,
    _ => C.passReleases(w, rest, stack, frame(), 0n, value, False{}, False{}, False{}, R.Healthy{}), _ => C.unwind(w, tasks, stack)), B.ok(w), True{}, ready)

def step_from_shape(-m: C.Machine, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value,
  shape: {m == C.Machine{w, C.PassReleases{frame(), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, stack} : C.Machine}, ready: {B.ok(w) == True{} : Bool}) ->
  {C.step(m) == C.passReleases(w, rest, stack, frame(), 0n, value, False{}, False{}, False{}, R.Healthy{}) : C.Machine}:
  Equal.trans(C.Machine, C.step(m), C.step(C.Machine{w, C.PassReleases{frame(), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, stack}), C.passReleases(w, rest, stack, frame(), 0n, value, False{}, False{}, False{}, R.Healthy{}),
    Equal.cong(C.Machine, C.Machine, state => C.step(state), m, C.Machine{w, C.PassReleases{frame(), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, stack}, shape),
    step_release(w, rest, stack, value, ready))

def resumeAt(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, value: R.Value) -> C.Machine:
  B.choose(~C.Machine, B.ok(w),
    _ => C.afterPass(w, rest, stack, 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{}),
    _ => C.Machine{w, rest, stack})

def afterRelease(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, value: R.Value) -> C.Machine:
  resumeAt(R.World.with_fault(C.passFinallyTail(w, 3n, False{}), R.Healthy{}), rest, stack, value)

def releaseLoaded(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value, +nodes: List<&2, Nat>) -> C.Machine:
  B.choose(~C.Machine, Nat.is_ge(0n, B.length(Nat, nodes)),
    _ => afterRelease(w, rest, stack, value),
    _ =>
      +node = B.get(Nat, nodes, 0n, 0n)
      +ending = {C.PassReleases{frame(), 1n, value, False{}, False{}, False{}, R.Healthy{}} <> rest : List<&2, C.Task>}
      C.Machine{w, B.choose(~List<&2, C.Task>, Q.releasable(w, node), _ => C.OwnerTasks{[O.Unobserved{node}]} <> ending, _ => ending), stack})

def release_empty(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value,
  empty: {B.get(List<&2, Nat>, R.World.releaseLists(w), 0n, []) == [] : List<&2, Nat>}) ->
  {C.passReleases(w, rest, stack, frame(), 0n, value, False{}, False{}, False{}, R.Healthy{}) == afterRelease(w, rest, stack, value) : C.Machine}:
  Equal.cong(List<&2, Nat>, C.Machine, nodes => releaseLoaded(w, rest, stack, value, nodes), B.get(List<&2, Nat>, R.World.releaseLists(w), 0n, []), [], empty)

def after_release_identity(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value,
  tail: {R.World.with_fault(C.passFinallyTail(w, 3n, False{}), R.Healthy{}) == w : R.World}, ready: {B.ok(w) == True{} : Bool}) ->
  {afterRelease(w, rest, stack, value) == C.afterPass(w, rest, stack, 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{}) : C.Machine}:
  Equal.trans(C.Machine, afterRelease(w, rest, stack, value), resumeAt(w, rest, stack, value), C.afterPass(w, rest, stack, 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{}),
    Equal.cong(R.World, C.Machine, state => resumeAt(state, rest, stack, value), R.World.with_fault(C.passFinallyTail(w, 3n, False{}), R.Healthy{}), w, tail),
    Equal.cong(Bool, C.Machine, healthy => B.choose(~C.Machine, healthy,
      _ => C.afterPass(w, rest, stack, 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{}), _ => C.Machine{w, rest, stack}), B.ok(w), True{}, ready))

# Abstract the real lane-stage call as its machine return point. Keeping the
# call opaque here avoids normalizing its recursive judgment on an unknown World.
def afterSeat(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +height: Nat, +errored: Bool, +seated: Nat) -> C.Machine:
  B.choose(~C.Machine, Nat.is_eq(seated, 0n),
    _ => C.publishState(w, C.FinishPublication{id, False{}, False{}, False{}, 0n, 0n} <> rest, stack, id, value, False{}, height, False{}, R.Number{0n}, 0n, False{}, False{}, errored, 0n, False{}),
    _ => C.Machine{w, C.PassLaneStage{id, False{}, value, height, False{}, R.Number{0n}, 0n, False{}, False{}, errored, False{}, 0n, seated, False{}} <> rest, stack})

def afterChoice(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +height: Nat, dead: Bool, +errored: Bool) -> C.Machine:
  B.choose(~C.Machine, dead,
    _ => C.Machine{w, C.OwnerTasks{[O.ClearDeps{id}]} <> C.AfterDeadPass{id, 0n} <> rest, stack},
    _ => afterSeat(w, rest, stack, id, value, height, errored, R.World.passLane(w)))

def afterLive(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +height: Nat,
  live: {B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED()) == False{} : Bool},
  clean: {Bool.or(B.truth(R.NodeExtension.error(B.extension(w, id))), False{}) == False{} : Bool},
  seat: {R.World.passLane(w) == 0n : Nat}) ->
  {C.afterPass(w, rest, stack, id, False{}, value, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
    == C.publishState(w, C.FinishPublication{id, False{}, False{}, False{}, 0n, 0n} <> rest, stack, id, value, False{}, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{}) : C.Machine}:
  +error = Bool.or(B.truth(R.NodeExtension.error(B.extension(w, id))), False{})
  Equal.trans(C.Machine, C.afterPass(w, rest, stack, id, False{}, value, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{}), afterChoice(w, rest, stack, id, value, height, False{}, error), C.publishState(w, C.FinishPublication{id, False{}, False{}, False{}, 0n, 0n} <> rest, stack, id, value, False{}, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{}),
    Equal.cong(Bool, C.Machine, dead => afterChoice(w, rest, stack, id, value, height, dead, error), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED()), False{}, live),
    Equal.trans(C.Machine, afterChoice(w, rest, stack, id, value, height, False{}, error), afterChoice(w, rest, stack, id, value, height, False{}, False{}), C.publishState(w, C.FinishPublication{id, False{}, False{}, False{}, 0n, 0n} <> rest, stack, id, value, False{}, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{}),
      Equal.cong(Bool, C.Machine, e => afterChoice(w, rest, stack, id, value, height, False{}, e), error, False{}, clean),
      Equal.cong(Nat, C.Machine, lane => afterSeat(w, rest, stack, id, value, height, False{}, lane), R.World.passLane(w), 0n, seat)))

def after_pass_live(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value,
  live: {B.has(R.Node.flags(B.node(w, 3n)), K.REACTIVE_DISPOSED()) == False{} : Bool},
  clean: {Bool.or(B.truth(R.NodeExtension.error(B.extension(w, 3n))), False{}) == False{} : Bool},
  seat: {R.World.passLane(w) == 0n : Nat}) ->
  {C.afterPass(w, rest, stack, 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
    == C.publishState(w, C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n} <> rest, stack, 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{}) : C.Machine}:
  afterLive(w, rest, stack, 3n, value, 0n, live, clean, seat)

# Keep API alias and canonical-machine conversions abstract. Unfolding an
# alias at a concrete graph would evaluate the entire run during conversion.
def api_flush(+fuel: Nat, +w: R.World,
  guard: {Bool.or(Nat.is_ne(R.World.actionDepth(w), 0n), Bool.or(R.World.halted(w), Bool.or(R.World.running(w), Bool.not(R.World.scheduled(w))))) == False{} : Bool}) ->
  {A.flush(fuel, w) == C.world(C.run(fuel, C.Machine{w, [C.Round{}], []})) : R.World}:
  P.flush_eq(fuel, w, guard)

def flush_from_shape(+fuel: Nat, +w: R.World, -start: C.Machine, -end: C.Machine,
  guard: {Bool.or(Nat.is_ne(R.World.actionDepth(w), 0n), Bool.or(R.World.halted(w), Bool.or(R.World.running(w), Bool.not(R.World.scheduled(w))))) == False{} : Bool},
  shape: {C.Machine{w, [C.Round{}], []} == start : C.Machine},
  finished: {C.run(fuel, start) == end : C.Machine}) ->
  {A.flush(fuel, w) == C.world(end) : R.World}:
  Equal.trans(R.World, A.flush(fuel, w), C.world(C.run(fuel, C.Machine{w, [C.Round{}], []})), C.world(end),
    api_flush(fuel, w, guard),
    Equal.trans(R.World, C.world(C.run(fuel, C.Machine{w, [C.Round{}], []})), C.world(C.run(fuel, start)), C.world(end),
      Equal.cong(C.Machine, R.World, machine => C.world(C.run(fuel, machine)), C.Machine{w, [C.Round{}], []}, start, shape),
      Equal.cong(C.Machine, R.World, machine => C.world(machine), C.run(fuel, start), end, finished)))

# Loaded source gates; no alternate publication engine. The non-guess domain
# is explicit and all complete scalar/graph callers discharge it.
def comparedChoice(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +create: Bool, +height: Nat, +outgoing: R.Value, +sources: Nat, +pendingSource: Bool, +joined: Bool, +changed: Bool, outcome: Bool) -> C.Machine:
  B.choose(~C.Machine, outcome,
    _ => C.Machine{C.markPublishedEffect(w, id, value, create, changed, 0n), C.LaneOutcomeStart{id, value, False{}} <> C.PublishOutcome{id, value, create, height, outgoing, sources, pendingSource, joined, changed} <> rest, stack},
    _ => C.publicationCompleted(rest, stack, id, outgoing, sources, pendingSource, C.publishValueChangedOutgoing(w, id, value, create, height, joined, changed,outgoing)))

def comparedPlain(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +create: Bool, +height: Nat, +outgoing: R.Value, +sources: Nat, +pendingSource: Bool, +joined: Bool, +changed: Bool,
  ordinary: {C.publicationOutcome(C.markPublishedEffect(w, id, value, create, changed, 0n), id, create, 0n) == False{} : Bool}) ->
  {C.publishCompared(w, rest, stack, id, value, create, height, outgoing, sources, pendingSource, joined, changed, 0n) == C.publicationCompleted(rest, stack, id, outgoing, sources, pendingSource, C.publishValueChangedOutgoing(w, id, value, create, height, joined, changed,outgoing)) : C.Machine}:
  Equal.cong(Bool, C.Machine, outcome => comparedChoice(w, rest, stack, id, value, create, height, outgoing, sources, pendingSource, joined, changed, outcome), C.publicationOutcome(C.markPublishedEffect(w, id, value, create, changed, 0n), id, create, 0n), False{}, ordinary)

def selected(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +create: Bool, +height: Nat, +uninitialized: Bool, +outgoing: R.Value, +sources: Nat, +pendingSource: Bool, +joined: Bool, +errored: Bool, +callback: Nat) -> C.Machine:
  B.choose(~C.Machine, errored, _ => C.Machine{w, rest, stack},
    _ => B.choose(~C.Machine, Nat.is_eq(callback, 0n),
      _ => C.publishCompared(w, rest, stack, id, value, create, height, outgoing, sources, pendingSource, joined, C.publicationChanged(w, id, value, uninitialized), 0n),
      _ => B.choose(~C.Machine, Bool.or(Bool.and(Bool.not(B.effect(R.Node.kind(B.node(w, id)))), uninitialized), Bool.or(B.truth(R.NodeExtension.shownError(B.extension(w, id))),False{})),
        _ => C.publishCompared(w, rest, stack, id, value, create, height, outgoing, sources, pendingSource, joined, True{}, 0n),
        _ => C.isSame(w, C.PublishCompared{id, value, create, height, uninitialized, outgoing, sources, pendingSource, joined, errored, 0n} <> rest, stack, id, C.passValue(w, id), value))))

def default_publish(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +create: Bool, +height: Nat, +uninitialized: Bool, +outgoing: R.Value, +sources: Nat, +pendingSource: Bool, +joined: Bool, +errored: Bool, +pair: B.Bundle<R.World, Bool>,
  clean: {errored == False{} : Bool},
  defaultEq: {EQ.custom(w, id) == 0n : Nat},
  ordinary: {C.publicationOutcome(C.markPublishedEffect(w, id, value, create, C.publicationChanged(w, id, value, uninitialized), 0n), id, create, 0n) == False{} : Bool},
  published: {C.publishValueOutgoing(w, id, value, create, height, uninitialized, joined,outgoing) == pair : B.Bundle<R.World, Bool>}) ->
  {C.publishState(w, rest, stack, id, value, create, height, uninitialized, outgoing, sources, pendingSource, joined, errored, 0n, False{}) == C.publicationCompleted(rest, stack, id, outgoing, sources, pendingSource, pair) : C.Machine}:
  Equal.trans(C.Machine, C.publishState(w, rest, stack, id, value, create, height, uninitialized, outgoing, sources, pendingSource, joined, errored, 0n, False{}), selected(w, rest, stack, id, value, create, height, uninitialized, outgoing, sources, pendingSource, joined, False{}, EQ.custom(w, id)), C.publicationCompleted(rest, stack, id, outgoing, sources, pendingSource, pair),
    Equal.cong(Bool, C.Machine, e => selected(w, rest, stack, id, value, create, height, uninitialized, outgoing, sources, pendingSource, joined, e, EQ.custom(w, id)), errored, False{}, clean),
    Equal.trans(C.Machine, selected(w, rest, stack, id, value, create, height, uninitialized, outgoing, sources, pendingSource, joined, False{}, EQ.custom(w, id)), C.publishCompared(w, rest, stack, id, value, create, height, outgoing, sources, pendingSource, joined, C.publicationChanged(w, id, value, uninitialized), 0n), C.publicationCompleted(rest, stack, id, outgoing, sources, pendingSource, pair),
      Equal.cong(Nat, C.Machine, cb => selected(w, rest, stack, id, value, create, height, uninitialized, outgoing, sources, pendingSource, joined, False{}, cb), EQ.custom(w, id), 0n, defaultEq),
      Equal.trans(C.Machine, C.publishCompared(w, rest, stack, id, value, create, height, outgoing, sources, pendingSource, joined, C.publicationChanged(w, id, value, uninitialized), 0n), C.publicationCompleted(rest, stack, id, outgoing, sources, pendingSource, C.publishValueOutgoing(w, id, value, create, height, uninitialized, joined,outgoing)), C.publicationCompleted(rest, stack, id, outgoing, sources, pendingSource, pair),
        comparedPlain(w, rest, stack, id, value, create, height, outgoing, sources, pendingSource, joined, C.publicationChanged(w, id, value, uninitialized), ordinary),
        Equal.cong(B.Bundle<R.World, Bool>, C.Machine, result => C.publicationCompleted(rest, stack, id, outgoing, sources, pendingSource, result), C.publishValueOutgoing(w, id, value, create, height, uninitialized, joined,outgoing), pair, published))))
