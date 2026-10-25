# Actual core queue/stack control after a visit. The resulting World is carried
# from that very Core.step, rather than equated to an expanded helper World.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ../runtime/pending.bend as Q
import ./owner-continuation.bend as Owner
import ./pending-continuation.bend as Stack
import ./pending-machine-shape.bend as Fields
import ./pending-visit-control.bend as Control

def work(machine: C.Machine) -> List<&2, C.Task>:
  match machine:
    case C.Machine{world, tasks, values}: tasks

def observedTasks(view: Control.View) -> List<&2, Q.Task>:
  match view:
    case Control.View{tasks, released}: tasks

def observedReleases(view: Control.View) -> List<&2, Nat>:
  match view:
    case Control.View{tasks, released}: released

def resumeQueue(+rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +result: Q.Machine) ->
  {work(C.pendingResume(rest, stack, result)) == C.PendingTasks{Fields.tasks(result), Fields.visits(result), Fields.releases(result), Fields.scheduled(result)} <> rest : List<&2, C.Task>}:
  match result:
    case Q.Machine{world, tasks, visited, released, scheduled}: {==}

def visitQueue(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, +source: Nat) ->
  {work(C.pendingTasks(w, rest, stack, Q.Visit{id, root, source} <> tail, visited, released, scheduled)) == C.PendingTasks{Fields.tasks(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled)), Fields.visits(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled)), Fields.releases(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled)), Fields.scheduled(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled))} <> rest : List<&2, C.Task>}:
  resumeQueue(rest, stack, Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled))

def input(w: R.World, tail: List<&2, Q.Task>, visited: List<&2, Nat>, released: List<&2, Nat>, scheduled: Bool, id: Nat, root: Nat, source: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  C.Machine{w, C.PendingTasks{Q.Visit{id, root, source} <> tail, visited, released, scheduled} <> rest, stack}

def stepQueue(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, +source: Nat, healthy: {C.healthy(R.World.fault(w)) == True{} : Bool}) ->
  {work(C.step(input(w, tail, visited, released, scheduled, id, root, source, rest, stack))) == C.PendingTasks{Fields.tasks(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled)), Fields.visits(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled)), Fields.releases(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled)), Fields.scheduled(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled))} <> rest : List<&2, C.Task>}:
  Equal.trans(List<&2, C.Task>, work(C.step(input(w, tail, visited, released, scheduled, id, root, source, rest, stack))), work(C.dispatch(w, C.PendingTasks{Q.Visit{id, root, source} <> tail, visited, released, scheduled} <> rest, stack)), C.PendingTasks{Fields.tasks(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled)), Fields.visits(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled)), Fields.releases(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled)), Fields.scheduled(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled))} <> rest,
    Equal.cong(C.Machine, List<&2, C.Task>, machine => work(machine), C.step(input(w, tail, visited, released, scheduled, id, root, source, rest, stack)), C.dispatch(w, C.PendingTasks{Q.Visit{id, root, source} <> tail, visited, released, scheduled} <> rest, stack), Owner.healthyStep(w, C.PendingTasks{Q.Visit{id, root, source} <> tail, visited, released, scheduled}, rest, stack, healthy)), visitQueue(w, rest, stack, tail, visited, released, scheduled, id, root, source))

def queueShape(+result: Q.Machine, +rest: List<&2, C.Task>, +tail: List<&2, Q.Task>, +released: List<&2, Nat>, +shape: {Control.observe(result) == Control.View{tail, released} : Control.View}) ->
  {C.PendingTasks{Fields.tasks(result), Fields.visits(result), Fields.releases(result), Fields.scheduled(result)} <> rest == C.PendingTasks{tail, Fields.visits(result), released, Fields.scheduled(result)} <> rest : List<&2, C.Task>}:
  +tasks = Equal.cong(Control.View, List<&2, Q.Task>, view => observedTasks(view), Control.observe(result), Control.View{tail, released}, shape)
  +releases = Equal.cong(Control.View, List<&2, Nat>, view => observedReleases(view), Control.observe(result), Control.View{tail, released}, shape)
  Equal.trans(List<&2, C.Task>, C.PendingTasks{Fields.tasks(result), Fields.visits(result), Fields.releases(result), Fields.scheduled(result)} <> rest, C.PendingTasks{tail, Fields.visits(result), Fields.releases(result), Fields.scheduled(result)} <> rest, C.PendingTasks{tail, Fields.visits(result), released, Fields.scheduled(result)} <> rest,
    Equal.cong(List<&2, Q.Task>, List<&2, C.Task>, work => C.PendingTasks{work, Fields.visits(result), Fields.releases(result), Fields.scheduled(result)} <> rest, Fields.tasks(result), tail, tasks),
    Equal.cong(List<&2, Nat>, List<&2, C.Task>, values => C.PendingTasks{tail, Fields.visits(result), values, Fields.scheduled(result)} <> rest, Fields.releases(result), released, releases))

def withWork(+machine: C.Machine, +tasks: List<&2, C.Task>, +stack: List<&2, R.Value>, queue: {work(machine) == tasks : List<&2, C.Task>}, values: {C.values(machine) == stack : List<&2, R.Value>}) ->
  {machine == C.Machine{C.world(machine), tasks, stack} : C.Machine}:
  match machine:
    case C.Machine{+world, +oldTasks, +oldValues}:
      Equal.trans(C.Machine, C.Machine{world, oldTasks, oldValues}, C.Machine{world, tasks, oldValues}, C.Machine{world, tasks, stack},
        Equal.cong(List<&2, C.Task>, C.Machine, next => C.Machine{world, next, oldValues}, oldTasks, tasks, queue), Equal.cong(List<&2, R.Value>, C.Machine, next => C.Machine{world, tasks, next}, oldValues, stack, values))

# A control observation supplies only queue data; stack safety is proved by the
# actual pending-step contract, and the exact computed Core World stays opaque.
def normalized(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, +source: Nat, +tasks: List<&2, Q.Task>, +remaining: List<&2, Nat>,
  healthy: {C.healthy(R.World.fault(w)) == True{} : Bool}, shape: {Control.observe(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled)) == Control.View{tasks, remaining} : Control.View}) ->
  {C.step(input(w, tail, visited, released, scheduled, id, root, source, rest, stack)) == C.Machine{C.world(C.step(input(w, tail, visited, released, scheduled, id, root, source, rest, stack))), C.PendingTasks{tasks, Fields.visits(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled)), remaining, Fields.scheduled(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled))} <> rest, stack} : C.Machine}:
  +result = Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, scheduled)
  +machine = C.step(input(w, tail, visited, released, scheduled, id, root, source, rest, stack))
  +queue = Equal.trans(List<&2, C.Task>, work(machine), C.PendingTasks{Fields.tasks(result), Fields.visits(result), Fields.releases(result), Fields.scheduled(result)} <> rest, C.PendingTasks{tasks, Fields.visits(result), remaining, Fields.scheduled(result)} <> rest,
    stepQueue(w, rest, stack, tail, visited, released, scheduled, id, root, source, healthy), queueShape(result, rest, tasks, remaining, shape))
  withWork(machine, C.PendingTasks{tasks, Fields.visits(result), remaining, Fields.scheduled(result)} <> rest, stack, queue, Stack.pendingStack(w, rest, stack, Q.Visit{id, root, source} <> tail, visited, released, scheduled))
