# A certified finite prefix of actual Core.step calls. Phase admits only source
# settlement/schedule and stack-neutral owner continuations. It cannot step a callback body or
# a flush. The height counts the prefix; it does not assert runtime completion.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/pending.bend as Q
import ../runtime/owner.bend as O
import ./owner-continuation.bend as Owner
import ./pending-continuation.bend as Stack

type Phase is Data:
  AfterTrim{id: Nat}
  Pending{tasks: List<&2, Q.Task>, visited: List<&2, Nat>, released: List<&2, Nat>, scheduled: Bool}
  Schedule{}
  OwnerWork{tasks: List<&2, O.Task>, allowed: {Owner.neutralHead(tasks) == True{} : Bool}}

def input(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, phase: Phase) -> C.Machine:
  match phase:
    case AfterTrim{id}: C.Machine{w, C.AsyncWriteAfterTrim{id} <> rest, stack}
    case Pending{tasks, visited, released, scheduled}: C.Machine{w, C.PendingTasks{tasks, visited, released, scheduled} <> rest, stack}
    case Schedule{}: C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack}
    case OwnerWork{tasks, allowed}: C.Machine{w, C.OwnerTasks{tasks} <> rest, stack}

def inputStack(w: R.World, rest: List<&2, C.Task>, +stack: List<&2, R.Value>, phase: Phase) ->
  {C.values(input(w, rest, stack, phase)) == stack : List<&2, R.Value>}:
  match phase:
    case AfterTrim{id}: {==}
    case Pending{tasks, visited, released, scheduled}: {==}
    case Schedule{}: {==}
    case OwnerWork{tasks, allowed}: {==}

def once(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +phase: Phase) ->
  {C.values(C.step(input(w, rest, stack, phase))) == stack : List<&2, R.Value>}:
  match phase:
    case AfterTrim{id}: Stack.afterTrimStepStack(w, rest, stack, id)
    case Pending{tasks, visited, released, scheduled}: Stack.pendingStack(w, rest, stack, tasks, visited, released, scheduled)
    case Schedule{}: Stack.scheduleStepStack(w, rest, stack)
    case OwnerWork{tasks, allowed}: Owner.stepStack(w, rest, stack, tasks, allowed)

def machineOnce(-m: C.Machine, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +phase: Phase,
  +layout: {m == input(w, rest, stack, phase) : C.Machine}) ->
  {C.values(C.step(m)) == C.values(m) : List<&2, R.Value>}:
  Equal.trans(List<&2, R.Value>, C.values(C.step(m)), C.values(C.step(input(w, rest, stack, phase))), C.values(m),
    Equal.cong(C.Machine, List<&2, R.Value>, actual => C.values(C.step(actual)), m, input(w, rest, stack, phase), layout),
    Equal.trans(List<&2, R.Value>, C.values(C.step(input(w, rest, stack, phase))), stack, C.values(m), once(w, rest, stack, phase),
      Equal.trans(List<&2, R.Value>, stack, C.values(input(w, rest, stack, phase)), C.values(m), Equal.sym(List<&2, R.Value>, C.values(input(w, rest, stack, phase)), stack, inputStack(w, rest, stack, phase)), Equal.sym(List<&2, R.Value>, C.values(m), C.values(input(w, rest, stack, phase)), Equal.cong(C.Machine, List<&2, R.Value>, actual => C.values(actual), m, input(w, rest, stack, phase), layout)))))

type Programme<-m: C.Machine> is Data:
  End{}
  Step{world: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, phase: Phase,
    layout: {m == input(world, rest, stack, phase) : C.Machine},
    tail: Programme<C.step(m)>}

def height(-scope: C.Machine, programme: Programme<scope>) -> Nat:
  match programme:
    case End{}: 0n
    case Step{world, rest, stack, phase, layout, tail}: 1n+height(C.step(scope), tail)

def run(-scope: C.Machine, programme: Programme<scope>, actual: C.Machine) -> C.Machine:
  match programme:
    case End{}: actual
    case Step{world, rest, stack, phase, layout, tail}: run(C.step(scope), tail, C.step(actual))

def iterate(length: Nat, actual: C.Machine) -> C.Machine:
  match length:
    case 0n: actual
    case 1n+n: iterate(n, C.step(actual))

def actualSteps(-scope: C.Machine, +programme: Programme<scope>, -actual: C.Machine) ->
  {run(scope, programme, actual) == iterate(height(scope, programme), actual) : C.Machine}:
  match programme:
    case End{}: {==}
    case Step{world, rest, stack, phase, layout, tail}: actualSteps(C.step(scope), tail, C.step(actual))

def preserves(-scope: C.Machine, +programme: Programme<scope>) ->
  {C.values(run(scope, programme, scope)) == C.values(scope) : List<&2, R.Value>}:
  match programme:
    case End{}: {==}
    case Step{world, rest, stack, phase, layout, +tail}:
      Equal.trans(List<&2, R.Value>, C.values(run(C.step(scope), tail, C.step(scope))), C.values(C.step(scope)), C.values(scope), preserves(C.step(scope), tail), machineOnce(scope, world, rest, stack, phase, layout))

def iterationStack(-scope: C.Machine, +programme: Programme<scope>) ->
  {C.values(iterate(height(scope, programme), scope)) == C.values(scope) : List<&2, R.Value>}:
  Equal.trans(List<&2, R.Value>, C.values(iterate(height(scope, programme), scope)), C.values(run(scope, programme, scope)), C.values(scope),
    Equal.sym(List<&2, R.Value>, C.values(run(scope, programme, scope)), C.values(iterate(height(scope, programme), scope)), Equal.cong(C.Machine, List<&2, R.Value>, actual => C.values(actual), run(scope, programme, scope), iterate(height(scope, programme), scope), actualSteps(scope, programme, scope))), preserves(scope, programme))

# Construct a nonempty permitted prefix for every World and caller stack. Both
# steps precede the caller's remaining tasks; a queued flush is not executed.
def emptyThenSchedule(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool) ->
  Programme<input(w, C.AsyncWriteSchedule{} <> rest, stack, Pending{[], visited, released, scheduled})>:
  Step{w, C.AsyncWriteSchedule{} <> rest, stack, Pending{[], visited, released, scheduled}, {==},
    Step{w, rest, stack, Schedule{}, Stack.emptyExact(w, C.AsyncWriteSchedule{} <> rest, stack, visited, released, scheduled), End{}}}

def emptyThenScheduleHeight(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, visited: List<&2, Nat>, released: List<&2, Nat>, scheduled: Bool) ->
  {height(input(w, C.AsyncWriteSchedule{} <> rest, stack, Pending{[], visited, released, scheduled}), emptyThenSchedule(w, rest, stack, visited, released, scheduled)) == 2n : Nat}:
  {==}

# A real trim plus owner return is admitted from graph/health inputs, without
# assuming its transition result or any caller-stack equation.
def ownerTrimPrefix(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat,
  edge: {Owner.staleEdge(w, id) == 0n : Nat}, healthy: {B.ok(w) == True{} : Bool}) ->
  Programme<input(w, rest, stack, OwnerWork{[O.TrimDeps{id}], {==}})>:
  Step{w, rest, stack, OwnerWork{[O.TrimDeps{id}], {==}}, {==},
    Step{w, rest, stack, OwnerWork{[], {==}}, Owner.trimNoStaleStep(w, rest, stack, id, [], edge, healthy), End{}}}

def ownerTrimHeight(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, id: Nat,
  edge: {Owner.staleEdge(w, id) == 0n : Nat}, healthy: {B.ok(w) == True{} : Bool}) ->
  {height(input(w, rest, stack, OwnerWork{[O.TrimDeps{id}], {==}}), ownerTrimPrefix(w, rest, stack, id, edge, healthy)) == 2n : Nat}:
  {==}
