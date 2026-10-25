# Actual owner driver stack contracts. Structural owner work may mutate graph,
# caches and disposal trace. User writes and callback bodies are separate phases.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/owner.bend as O
import ./async-write-prefix.bend as Prefix

def neutral(task: O.Task) -> Bool:
  match task:
    case O.WriteValue{signal, current, value}: False{}
    case O.WriteForward{signal, value}: False{}
    case O.Action{callback, action}: False{}
    case other: True{}

def neutralHead(tasks: List<&2, O.Task>) -> Bool:
  match tasks:
    case Nil{}: True{}
    case first <> rest: neutral(first)

def resumeStack(rest: List<&2, C.Task>, +stack: List<&2, R.Value>, machine: O.Machine) ->
  {C.values(C.ownerResume(rest, stack, machine)) == stack : List<&2, R.Value>}:
  match machine:
    case O.Machine{world, tasks}: {==}

def falseType(b: Bool) -> Data:
  match b:
    case False{}: Unit
    case True{}: Empty

def impossible(e: {False{} == True{} : Bool}) -> Empty:
  %e : falseType(_)
  Unit{}

def firstStack(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, first: O.Task, +tail: List<&2, O.Task>, allowed: {neutral(first) == True{} : Bool}) ->
  {C.values(C.ownerTasks(w, rest, stack, first <> tail)) == stack : List<&2, R.Value>}:
  match first:
    case O.Enter{id, self, zombie}: resumeStack(rest, stack, O.dispatch(w, O.Enter{id, self, zombie} <> tail))
    case O.AfterPark{id, self, zombie, flags}: resumeStack(rest, stack, O.dispatch(w, O.AfterPark{id, self, zombie, flags} <> tail))
    case O.Walk{id, self, zombie, flags, child}: resumeStack(rest, stack, O.dispatch(w, O.Walk{id, self, zombie, flags, child} <> tail))
    case O.AfterChild{id, self, zombie, flags, child}: resumeStack(rest, stack, O.dispatch(w, O.AfterChild{id, self, zombie, flags, child} <> tail))
    case O.PrepareChild{id, self, zombie, flags, child}: resumeStack(rest, stack, O.dispatch(w, O.PrepareChild{id, self, zombie, flags, child} <> tail))
    case O.Finish{id, self, zombie, flags}: resumeStack(rest, stack, O.dispatch(w, O.Finish{id, self, zombie, flags} <> tail))
    case O.RunDisposal{id, self, zombie}: resumeStack(rest, stack, O.dispatch(w, O.RunDisposal{id, self, zombie} <> tail))
    case O.DisposalLoop{callbacks, count}: resumeStack(rest, stack, O.dispatch(w, O.DisposalLoop{callbacks, count} <> tail))
    case O.EffectCleanup{id, self}: resumeStack(rest, stack, O.dispatch(w, O.EffectCleanup{id, self} <> tail))
    case O.Invoke{callback}: {==}
    case O.RunCleanup{callback}: {==}
    case O.CleanupFinally{}: resumeStack(rest, stack, O.dispatch(w, O.CleanupFinally{} <> tail))
    case O.RootEnd{}: resumeStack(rest, stack, O.dispatch(w, O.RootEnd{} <> tail))
    case O.Action{callback, action}: Empty.absurd({C.values(C.ownerTasks(w, rest, stack, O.Action{callback, action} <> tail)) == stack : List<&2, R.Value>}, impossible(allowed))
    case O.WriteValue{signal, current, value}: Empty.absurd({C.values(C.ownerTasks(w, rest, stack, O.WriteValue{signal, current, value} <> tail)) == stack : List<&2, R.Value>}, impossible(allowed))
    case O.WriteForward{signal, value}: Empty.absurd({C.values(C.ownerTasks(w, rest, stack, O.WriteForward{signal, value} <> tail)) == stack : List<&2, R.Value>}, impossible(allowed))
    case O.WriteMemoFinish{signal, held}: resumeStack(rest, stack, O.dispatch(w, O.WriteMemoFinish{signal, held} <> tail))
    case O.Dispose{id}: resumeStack(rest, stack, O.dispatch(w, O.Dispose{id} <> tail))
    case O.MarkChildren{id}: resumeStack(rest, stack, O.dispatch(w, O.MarkChildren{id} <> tail))
    case O.MarkChild{child}: resumeStack(rest, stack, O.dispatch(w, O.MarkChild{child} <> tail))
    case O.MarkNext{child}: resumeStack(rest, stack, O.dispatch(w, O.MarkNext{child} <> tail))
    case O.ClearDeps{id}: resumeStack(rest, stack, O.dispatch(w, O.ClearDeps{id} <> tail))
    case O.ClearDepSlots{id}: resumeStack(rest, stack, O.dispatch(w, O.ClearDepSlots{id} <> tail))
    case O.TrimDeps{id}: resumeStack(rest, stack, O.dispatch(w, O.TrimDeps{id} <> tail))
    case O.TrimDepSlots{id, retainedTail}: resumeStack(rest, stack, O.dispatch(w, O.TrimDepSlots{id, retainedTail} <> tail))
    case O.UnlinkLoop{edge}: resumeStack(rest, stack, O.dispatch(w, O.UnlinkLoop{edge} <> tail))
    case O.UnlinkOnce{edge}: resumeStack(rest, stack, O.dispatch(w, O.UnlinkOnce{edge} <> tail))
    case O.AfterUnobservedHook{id}: resumeStack(rest, stack, O.dispatch(w, O.AfterUnobservedHook{id} <> tail))
    case O.Unobserved{id}: resumeStack(rest, stack, O.dispatch(w, O.Unobserved{id} <> tail))
    case O.SweepDormant{index}: resumeStack(rest, stack, O.dispatch(w, O.SweepDormant{index} <> tail))
    case O.ClearDormant{}: resumeStack(rest, stack, O.dispatch(w, O.ClearDormant{} <> tail))

def tasksStack(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, tasks: List<&2, O.Task>, allowed: {neutralHead(tasks) == True{} : Bool}) ->
  {C.values(C.ownerTasks(w, rest, stack, tasks)) == stack : List<&2, R.Value>}:
  match tasks:
    case Nil{}: {==}
    case first <> tail: firstStack(w, rest, stack, first, tail, allowed)

def stepStack(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +tasks: List<&2, O.Task>, allowed: {neutralHead(tasks) == True{} : Bool}) ->
  {C.values(C.step(C.Machine{w, C.OwnerTasks{tasks} <> rest, stack})) == stack : List<&2, R.Value>}:
  +head = {C.OwnerTasks{tasks} : C.Task}
  Prefix.valuesChoice(B.ok(w), stack, C.dispatch(w, head <> rest, stack), C.unwind(w, head <> rest, stack), tasksStack(w, rest, stack, tasks, allowed), {==})

# The source trim selector: the stale suffix starts after the retained tail,
# otherwise it starts at the dependency head. This is an input graph fact.
def staleEdge(+w: R.World, +id: Nat) -> Nat:
  +tail = R.Node.depsTail(B.node(w, id))
  B.choose(~Nat, Nat.is_ne(tail, 0n), _ => R.Link.nextDep(B.link(w, tail)), _ => R.Node.deps(B.node(w, id)))

def trimNoStale(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +tail: List<&2, O.Task>, edge: {staleEdge(w, id) == 0n : Nat}) ->
  {C.dispatch(w, C.OwnerTasks{O.TrimDeps{id} <> tail} <> rest, stack) == C.Machine{w, C.OwnerTasks{tail} <> rest, stack} : C.Machine}:
  Equal.cong(Nat, C.Machine, edge => C.ownerResume(rest, stack, B.choose(~O.Machine, Nat.is_eq(edge, 0n), _ => O.Machine{w, tail}, _ => O.Machine{w, O.UnlinkLoop{edge} <> O.TrimDepSlots{id, R.Node.depsTail(B.node(w, id))} <> tail})), staleEdge(w, id), 0n, edge)

def healthyStep(+w: R.World, +head: C.Task, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.step(C.Machine{w, head <> rest, stack}) == C.dispatch(w, head <> rest, stack) : C.Machine}:
  Equal.cong(Bool, C.Machine, ready => B.choose(~C.Machine, ready, _ => C.dispatch(w, head <> rest, stack), _ => C.unwind(w, head <> rest, stack)), B.ok(w), True{}, healthy)

def trimNoStaleStep(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +tail: List<&2, O.Task>, edge: {staleEdge(w, id) == 0n : Nat}, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.step(C.Machine{w, C.OwnerTasks{O.TrimDeps{id} <> tail} <> rest, stack}) == C.Machine{w, C.OwnerTasks{tail} <> rest, stack} : C.Machine}:
  Equal.trans(C.Machine, C.step(C.Machine{w, C.OwnerTasks{O.TrimDeps{id} <> tail} <> rest, stack}), C.dispatch(w, C.OwnerTasks{O.TrimDeps{id} <> tail} <> rest, stack), C.Machine{w, C.OwnerTasks{tail} <> rest, stack}, healthyStep(w, C.OwnerTasks{O.TrimDeps{id} <> tail}, rest, stack, healthy), trimNoStale(w, rest, stack, id, tail, edge))

def sameChoice(+condition: Bool, +machine: C.Machine) ->
  {B.choose(~C.Machine, condition, _ => machine, _ => machine) == machine : C.Machine}:
  match condition:
    case True{}: {==}
    case False{}: {==}

def emptyExact(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>) ->
  {C.step(C.Machine{w, C.OwnerTasks{[]} <> rest, stack}) == C.Machine{w, rest, stack} : C.Machine}:
  sameChoice(B.ok(w), C.Machine{w, rest, stack})

# Exact internal completion of one no-stale dependency trim, including return
# from its owner frame. The caller's queued flush is retained, never executed.
def trimComplete(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, edge: {staleEdge(w, id) == 0n : Nat}, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.step(C.step(C.Machine{w, C.OwnerTasks{[O.TrimDeps{id}]} <> rest, stack})) == C.Machine{w, rest, stack} : C.Machine}:
  +start = {C.Machine{w, C.OwnerTasks{[O.TrimDeps{id}]} <> rest, stack} : C.Machine}
  +after = {C.Machine{w, C.OwnerTasks{[]} <> rest, stack} : C.Machine}
  Equal.trans(C.Machine, C.step(C.step(start)), C.step(after), C.Machine{w, rest, stack}, Equal.cong(C.Machine, C.Machine, machine => C.step(machine), C.step(start), after, trimNoStaleStep(w, rest, stack, id, [], edge, healthy)), emptyExact(w, rest, stack))
