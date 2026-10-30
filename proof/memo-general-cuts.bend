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

# Previous value is arbitrary; source frame flags and all other fields stay fixed.
def frame(previous: R.Value) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, previous, False{}, R.Number{0n}, 0n, False{}, R.FlightUndefined{}, [], 0n, False{}, C.LanePass{0n, R.MountUnset{}, R.MountFalse{}, False{}}}

def step_release(+previous: R.Value, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value, ready: {B.ok(w) == True{} : Bool}) ->
  {C.step(C.Machine{w, C.PassReleases{frame(previous), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, stack})
    == C.passReleases(w, rest, stack, frame(previous), 0n, value, False{}, False{}, False{}, R.Healthy{}) : C.Machine}:
  +tasks = {C.PassReleases{frame(previous), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest : List<&2, C.Task>}
  Equal.cong(Bool, C.Machine, healthy => B.choose(~C.Machine, healthy,
    _ => C.passReleases(w, rest, stack, frame(previous), 0n, value, False{}, False{}, False{}, R.Healthy{}), _ => C.unwind(w, tasks, stack)), B.ok(w), True{}, ready)

def step_from_shape(+previous: R.Value, -m: C.Machine, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value,
  shape: {m == C.Machine{w, C.PassReleases{frame(previous), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, stack} : C.Machine}, ready: {B.ok(w) == True{} : Bool}) ->
  {C.step(m) == C.passReleases(w, rest, stack, frame(previous), 0n, value, False{}, False{}, False{}, R.Healthy{}) : C.Machine}:
  Equal.trans(C.Machine, C.step(m), C.step(C.Machine{w, C.PassReleases{frame(previous), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, stack}), C.passReleases(w, rest, stack, frame(previous), 0n, value, False{}, False{}, False{}, R.Healthy{}),
    Equal.cong(C.Machine, C.Machine, state => C.step(state), m, C.Machine{w, C.PassReleases{frame(previous), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, stack}, shape),
    step_release(previous, w, rest, stack, value, ready))

def releaseLoaded(+previous: R.Value, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value, +nodes: List<&2, Nat>) -> C.Machine:
  B.choose(~C.Machine, Nat.is_ge(0n, B.length(Nat, nodes)),
    _ => Existing.afterRelease(w, rest, stack, value),
    _ =>
      +node = B.get(Nat, nodes, 0n, 0n)
      +ending = {C.PassReleases{frame(previous), 1n, value, False{}, False{}, False{}, R.Healthy{}} <> rest : List<&2, C.Task>}
      C.Machine{w, B.choose(~List<&2, C.Task>, Q.releasable(w, node), _ => C.OwnerTasks{[O.Unobserved{node}]} <> ending, _ => ending), stack})

def release_empty(+previous: R.Value, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +value: R.Value,
  empty: {B.get(List<&2, Nat>, R.World.releaseLists(w), 0n, []) == [] : List<&2, Nat>}) ->
  {C.passReleases(w, rest, stack, frame(previous), 0n, value, False{}, False{}, False{}, R.Healthy{}) == Existing.afterRelease(w, rest, stack, value) : C.Machine}:
  Equal.cong(List<&2, Nat>, C.Machine, nodes => releaseLoaded(previous, w, rest, stack, value, nodes), B.get(List<&2, Nat>, R.World.releaseLists(w), 0n, []), [], empty)
