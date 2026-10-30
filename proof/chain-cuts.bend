import Base
import ./memo-cuts.bend as Existing
import ../runtime/equality.bend as EQ
import ../runtime/api.bend as A
import ../proof/paths.bend as P
import ../runtime/core.bend as C
import ../runtime/owner.bend as O
import ../runtime/pending.bend as Q
import ../runtime/constants.bend as K
import ../representation/base.bend as B
import ../representation/records.bend as R

# Successful recompute frame, parameterized by node, height and previous value.
def frame(id: Nat, height: Nat, previous: R.Value) -> C.PassFrame:
  C.PassFrame{id, False{}, 0n, False{}, height, False{}, previous, False{}, R.Number{0n}, 0n, False{}, R.FlightUndefined{}, [], 0n, False{}, C.LanePass{0n, R.MountUnset{}, R.MountFalse{}, False{}}}

def step_release(+id: Nat, +height: Nat, +previous: R.Value, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value, ready: {B.ok(w) == True{} : Bool}) ->
  {C.step(C.Machine{w, C.PassReleases{frame(id, height, previous), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, stack})
    == C.passReleases(w, rest, stack, frame(id, height, previous), 0n, value, False{}, False{}, False{}, R.Healthy{}) : C.Machine}:
  +tasks = {C.PassReleases{frame(id, height, previous), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest : List<&2, C.Task>}
  Equal.cong(Bool, C.Machine, healthy => B.choose(~C.Machine, healthy,
    _ => C.passReleases(w, rest, stack, frame(id, height, previous), 0n, value, False{}, False{}, False{}, R.Healthy{}), _ => C.unwind(w, tasks, stack)), B.ok(w), True{}, ready)

def step_from_shape(+id: Nat, +height: Nat, +previous: R.Value, -m: C.Machine, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value,
  shape: {m == C.Machine{w, C.PassReleases{frame(id, height, previous), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, stack} : C.Machine}, ready: {B.ok(w) == True{} : Bool}) ->
  {C.step(m) == C.passReleases(w, rest, stack, frame(id, height, previous), 0n, value, False{}, False{}, False{}, R.Healthy{}) : C.Machine}:
  Equal.trans(C.Machine, C.step(m), C.step(C.Machine{w, C.PassReleases{frame(id, height, previous), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, stack}), C.passReleases(w, rest, stack, frame(id, height, previous), 0n, value, False{}, False{}, False{}, R.Healthy{}),
    Equal.cong(C.Machine, C.Machine, state => C.step(state), m, C.Machine{w, C.PassReleases{frame(id, height, previous), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, stack}, shape),
    step_release(id, height, previous, w, rest, stack, value, ready))

def resumeAt(+id: Nat, +height: Nat, +previous: R.Value, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, value: R.Value) -> C.Machine:
  B.choose(~C.Machine, B.ok(w),
    _ => C.afterPass(w, rest, stack, id, False{}, value, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{}),
    _ => C.Machine{w, rest, stack})

def afterRelease(+id: Nat, +height: Nat, +previous: R.Value, w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, value: R.Value) -> C.Machine:
  resumeAt(id, height, previous, R.World.with_fault(C.passFinallyTail(w, id, False{}), R.Healthy{}), rest, stack, value)

def releaseLoaded(+id: Nat, +height: Nat, +previous: R.Value, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value, +nodes: List<&2, Nat>) -> C.Machine:
  B.choose(~C.Machine, Nat.is_ge(0n, B.length(Nat, nodes)),
    _ => afterRelease(id, height, previous, w, rest, stack, value),
    _ =>
      +node = B.get(Nat, nodes, 0n, 0n)
      +ending = {C.PassReleases{frame(id, height, previous), 1n, value, False{}, False{}, False{}, R.Healthy{}} <> rest : List<&2, C.Task>}
      C.Machine{w, B.choose(~List<&2, C.Task>, Q.releasable(w, node), _ => C.OwnerTasks{[O.Unobserved{node}]} <> ending, _ => ending), stack})

def release_empty(+id: Nat, +height: Nat, +previous: R.Value, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value,
  empty: {B.get(List<&2, Nat>, R.World.releaseLists(w), 0n, []) == [] : List<&2, Nat>}) ->
  {C.passReleases(w, rest, stack, frame(id, height, previous), 0n, value, False{}, False{}, False{}, R.Healthy{}) == afterRelease(id, height, previous, w, rest, stack, value) : C.Machine}:
  Equal.cong(List<&2, Nat>, C.Machine, nodes => releaseLoaded(id, height, previous, w, rest, stack, value, nodes), B.get(List<&2, Nat>, R.World.releaseLists(w), 0n, []), [], empty)

def after_release_identity(+id: Nat, +height: Nat, +previous: R.Value, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value,
  tail: {R.World.with_fault(C.passFinallyTail(w, id, False{}), R.Healthy{}) == w : R.World}, ready: {B.ok(w) == True{} : Bool}) ->
  {afterRelease(id, height, previous, w, rest, stack, value) == C.afterPass(w, rest, stack, id, False{}, value, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{}) : C.Machine}:
  Equal.trans(C.Machine, afterRelease(id, height, previous, w, rest, stack, value), resumeAt(id, height, previous, w, rest, stack, value), C.afterPass(w, rest, stack, id, False{}, value, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{}),
    Equal.cong(R.World, C.Machine, state => resumeAt(id, height, previous, state, rest, stack, value), R.World.with_fault(C.passFinallyTail(w, id, False{}), R.Healthy{}), w, tail),
    Equal.cong(Bool, C.Machine, healthy => B.choose(~C.Machine, healthy,
      _ => C.afterPass(w, rest, stack, id, False{}, value, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{}), _ => C.Machine{w, rest, stack}), B.ok(w), True{}, ready))

def after_pass_live(+id: Nat, +height: Nat, +previous: R.Value, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value,
  live: {B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED()) == False{} : Bool},
  clean: {Bool.or(B.truth(R.NodeExtension.error(B.extension(w, id))), False{}) == False{} : Bool},
  seat: {R.World.passLane(w) == 0n : Nat}) ->
  {C.afterPass(w, rest, stack, id, False{}, value, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
    == C.publishState(w, C.FinishPublication{id, False{}, False{}, False{}, 0n, 0n} <> rest, stack, id, value, False{}, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{}) : C.Machine}:
  Existing.afterLive(w, rest, stack, id, value, height, live, clean, seat)
