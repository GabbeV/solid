# Source core continuations execute the pending traversal. Owner callbacks and
# AsyncFlush are retained in the queue and are not traversed by these contracts.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/pending.bend as Q
import ../runtime/owner.bend as O
import ./async-write-prefix.bend as Prefix

def resumeStack(rest: List<&2, C.Task>, +stack: List<&2, R.Value>, machine: Q.Machine) ->
  {C.values(C.pendingResume(rest, stack, machine)) == stack : List<&2, R.Value>}:
  match machine:
    case Q.Machine{w, tasks, visited, released, scheduled}: {==}

def tasksStack(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool) ->
  {C.values(C.pendingTasks(w, rest, stack, tasks, visited, released, scheduled)) == stack : List<&2, R.Value>}:
  match tasks:
    case Nil{}: {==}
    case Q.Release{+index} <> +tail:
      +id = B.get(Nat, released, index, 0n)
      +again = {C.PendingTasks{Q.Release{1n+index} <> tail, visited, released, scheduled} <> rest : List<&2, C.Task>}
      Prefix.valuesChoice(Nat.is_ge(index, B.length(Nat, released)), stack, C.Machine{w, C.PendingTasks{tail, visited, released, scheduled} <> rest, stack}, C.Machine{w, B.choose(~List<&2, C.Task>, Q.releasable(w, id), _ => C.OwnerTasks{[O.Unobserved{id}]} <> again, _ => again), stack}, {==}, {==})
    case Q.Visit{id, root, source} <> tail: resumeStack(rest, stack, Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled))
    case Q.Walk{edge, root, source} <> tail: resumeStack(rest, stack, Q.advance(w, Q.Walk{edge, root, source} <> tail, visited, released, scheduled))
    case Q.Next{edge, root, source} <> tail: resumeStack(rest, stack, Q.advance(w, Q.Next{edge, root, source} <> tail, visited, released, scheduled))
    case Q.Collect{id} <> tail: resumeStack(rest, stack, Q.advance(w, Q.Collect{id} <> tail, visited, released, scheduled))
    case Q.CollectWalk{edge} <> tail: resumeStack(rest, stack, Q.advance(w, Q.CollectWalk{edge} <> tail, visited, released, scheduled))
    case Q.CollectNext{edge} <> tail: resumeStack(rest, stack, Q.advance(w, Q.CollectNext{edge} <> tail, visited, released, scheduled))
    case Q.End{} <> tail: resumeStack(rest, stack, Q.advance(w, Q.End{} <> tail, visited, released, scheduled))

def pendingStack(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool) ->
  {C.values(C.step(C.Machine{w, C.PendingTasks{tasks, visited, released, scheduled} <> rest, stack})) == stack : List<&2, R.Value>}:
  +head = {C.PendingTasks{tasks, visited, released, scheduled} : C.Task}
  Prefix.valuesChoice(B.ok(w), stack, C.dispatch(w, head <> rest, stack), C.unwind(w, head <> rest, stack), tasksStack(w, rest, stack, tasks, visited, released, scheduled), {==})

def afterTrimExact(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, id: Nat) ->
  {C.dispatch(w, C.AsyncWriteAfterTrim{id} <> rest, stack) == C.pendingResume(rest, stack, Q.beginSettlement(w, id, id)) : C.Machine}:
  {==}

def afterTrimStack(w: R.World, rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat) ->
  {C.values(C.dispatch(w, C.AsyncWriteAfterTrim{id} <> rest, stack)) == stack : List<&2, R.Value>}:
  resumeStack(rest, stack, Q.beginSettlement(w, id, id))

def scheduleStack(w: R.World, rest: List<&2, C.Task>, +stack: List<&2, R.Value>) ->
  {C.values(C.dispatch(w, C.AsyncWriteSchedule{} <> rest, stack)) == stack : List<&2, R.Value>}:
  {==}

def afterTrimStepStack(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat) ->
  {C.values(C.step(C.Machine{w, C.AsyncWriteAfterTrim{id} <> rest, stack})) == stack : List<&2, R.Value>}:
  Prefix.valuesChoice(B.ok(w), stack, C.dispatch(w, C.AsyncWriteAfterTrim{id} <> rest, stack), C.unwind(w, C.AsyncWriteAfterTrim{id} <> rest, stack), afterTrimStack(w, rest, stack, id), {==})

def scheduleStepStack(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>) ->
  {C.values(C.step(C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack})) == stack : List<&2, R.Value>}:
  Prefix.valuesChoice(B.ok(w), stack, C.dispatch(w, C.AsyncWriteSchedule{} <> rest, stack), C.unwind(w, C.AsyncWriteSchedule{} <> rest, stack), scheduleStack(w, rest, stack), {==})

# Exact source release boundary: private visited/released/scheduled locals and
# the advanced release cursor stay captured across a queued owner callback.
def releaseExact(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +index: Nat, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool) ->
  {C.pendingTasks(w, rest, stack, Q.Release{index} <> tail, visited, released, scheduled) ==
    B.choose(~C.Machine, Nat.is_ge(index, B.length(Nat, released)),
      _ => C.Machine{w, C.PendingTasks{tail, visited, released, scheduled} <> rest, stack},
      _ =>
        +id = B.get(Nat, released, index, 0n)
        +again = {C.PendingTasks{Q.Release{1n+index} <> tail, visited, released, scheduled} <> rest : List<&2, C.Task>}
        C.Machine{w, B.choose(~List<&2, C.Task>, Q.releasable(w, id), _ => C.OwnerTasks{[O.Unobserved{id}]} <> again, _ => again), stack}) : C.Machine}:
  {==}

def sameChoice(+condition: Bool, +machine: C.Machine) ->
  {B.choose(~C.Machine, condition, _ => machine, _ => machine) == machine : C.Machine}:
  match condition:
    case True{}: {==}
    case False{}: {==}

# An exhausted local queue returns to the exact caller in both normal dispatch
# and fault unwinding. This is queue completion, not successful settlement.
def emptyExact(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, visited: List<&2, Nat>, released: List<&2, Nat>, scheduled: Bool) ->
  {C.step(C.Machine{w, C.PendingTasks{[], visited, released, scheduled} <> rest, stack}) == C.Machine{w, rest, stack} : C.Machine}:
  sameChoice(B.ok(w), C.Machine{w, rest, stack})
