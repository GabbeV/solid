# Actual callback-free Core settlement steps preserve committed storage.
# Owner release is queued and not executed; faults unwind without publishing.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/pending.bend as Q
import ../runtime/owner.bend as O
import ./committed-storage-frame.bend as Frame
import ./pending-settlement-frame.bend as Pending

def machineChoice(+condition: Bool, +w: R.World, +left: C.Machine, +right: C.Machine,
  leftFrame: {Frame.observe(C.world(left)) == Frame.observe(w) : Frame.View},
  rightFrame: {Frame.observe(C.world(right)) == Frame.observe(w) : Frame.View}) ->
  {Frame.observe(C.world(B.choose(~C.Machine, condition, _ => left, _ => right))) == Frame.observe(w) : Frame.View}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

def resume(+rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +machine: Q.Machine) ->
  {C.world(C.pendingResume(rest, stack, machine)) == Pending.world(machine) : R.World}:
  match machine:
    case Q.Machine{world, tasks, visited, released, scheduled}: {==}

def resumed(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +machine: Q.Machine,
  frame: {Frame.observe(Pending.world(machine)) == Frame.observe(w) : Frame.View}) ->
  {Frame.observe(C.world(C.pendingResume(rest, stack, machine))) == Frame.observe(w) : Frame.View}:
  Equal.trans(Frame.View, Frame.observe(C.world(C.pendingResume(rest, stack, machine))), Frame.observe(Pending.world(machine)), Frame.observe(w),
    Equal.cong(R.World, Frame.View, next => Frame.observe(next), C.world(C.pendingResume(rest, stack, machine)), Pending.world(machine), resume(rest, stack, machine)), frame)

def tasksFrame(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool) ->
  {Frame.observe(C.world(C.pendingTasks(w, rest, stack, tasks, visited, released, scheduled))) == Frame.observe(w) : Frame.View}:
  match tasks:
    case Nil{}: {==}
    case Q.Release{+index} <> +tail:
      +id = B.get(Nat, released, index, 0n)
      +again = {C.PendingTasks{Q.Release{1n+index} <> tail, visited, released, scheduled} <> rest : List<&2, C.Task>}
      machineChoice(Nat.is_ge(index, B.length(Nat, released)), w,
        C.Machine{w, C.PendingTasks{tail, visited, released, scheduled} <> rest, stack},
        C.Machine{w, B.choose(~List<&2, C.Task>, Q.releasable(w, id), _ => C.OwnerTasks{[O.Unobserved{id}]} <> again, _ => again), stack}, {==}, {==})
    case Q.Visit{id, root, source} <> tail: resumed(w, rest, stack, Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled), Pending.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled))
    case Q.Walk{edge, root, source} <> tail: resumed(w, rest, stack, Q.advance(w, Q.Walk{edge, root, source} <> tail, visited, released, scheduled), Pending.advance(w, Q.Walk{edge, root, source} <> tail, visited, released, scheduled))
    case Q.Next{edge, root, source} <> tail: resumed(w, rest, stack, Q.advance(w, Q.Next{edge, root, source} <> tail, visited, released, scheduled), Pending.advance(w, Q.Next{edge, root, source} <> tail, visited, released, scheduled))
    case Q.Collect{id} <> tail: resumed(w, rest, stack, Q.advance(w, Q.Collect{id} <> tail, visited, released, scheduled), Pending.advance(w, Q.Collect{id} <> tail, visited, released, scheduled))
    case Q.CollectWalk{edge} <> tail: resumed(w, rest, stack, Q.advance(w, Q.CollectWalk{edge} <> tail, visited, released, scheduled), Pending.advance(w, Q.CollectWalk{edge} <> tail, visited, released, scheduled))
    case Q.CollectNext{edge} <> tail: resumed(w, rest, stack, Q.advance(w, Q.CollectNext{edge} <> tail, visited, released, scheduled), Pending.advance(w, Q.CollectNext{edge} <> tail, visited, released, scheduled))
    case Q.End{} <> tail: resumed(w, rest, stack, Q.advance(w, Q.End{} <> tail, visited, released, scheduled), Pending.advance(w, Q.End{} <> tail, visited, released, scheduled))

def step(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool) ->
  {Frame.observe(C.world(C.step(C.Machine{w, C.PendingTasks{tasks, visited, released, scheduled} <> rest, stack}))) == Frame.observe(w) : Frame.View}:
  machineChoice(B.ok(w), w, C.dispatch(w, C.PendingTasks{tasks, visited, released, scheduled} <> rest, stack), C.unwind(w, C.PendingTasks{tasks, visited, released, scheduled} <> rest, stack), tasksFrame(w, rest, stack, tasks, visited, released, scheduled), {==})

def afterTrim(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat) ->
  {Frame.observe(C.world(C.step(C.Machine{w, C.AsyncWriteAfterTrim{id} <> rest, stack}))) == Frame.observe(w) : Frame.View}:
  machineChoice(B.ok(w), w, C.dispatch(w, C.AsyncWriteAfterTrim{id} <> rest, stack), C.unwind(w, C.AsyncWriteAfterTrim{id} <> rest, stack), resumed(w, rest, stack, Q.beginSettlement(w, id, id), Pending.begin(w, id, id)), {==})

def schedule(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>) ->
  {Frame.observe(C.world(C.step(C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack}))) == Frame.observe(w) : Frame.View}:
  machineChoice(B.ok(w), w, C.dispatch(w, C.AsyncWriteSchedule{} <> rest, stack), C.unwind(w, C.AsyncWriteSchedule{} <> rest, stack), Frame.schedule(w), {==})
