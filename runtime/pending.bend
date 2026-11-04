# core/async.ts settlePendingSource / releaseSettledDependents. Source live
# dependent traversal completes before deferred unobserved() release.
import Base
import ./pending-queue.bend as Intake
import ./dependent-walk.bend as Walk
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./pending-state.bend as P
import ./status.bend as A
import ./heap.bend as H
import ./owner.bend as O
import ./constants.bend as K
import ./transaction.bend as X

type Task is Data:
  Visit{id: Nat, root: Nat, source: Nat}
  Walk{edge: Nat, root: Nat, source: Nat}
  Next{edge: Nat, root: Nat, source: Nat}
  Descend{id: Nat, root: Nat, source: Nat}
  Collect{id: Nat}
  CollectWalk{edge: Nat}
  CollectNext{edge: Nat}
  Release{index: Nat}
  RestoreSettlement{visited: List<&2, Nat>, released: List<&2, Nat>, scheduled: Bool}
  End{}

type Machine is Data:
  Machine{world: R.World, tasks: List<&2, Task>, visited: List<&2, Nat>, released: List<&2, Nat>, scheduled: Bool}

def releasable(+w: R.World, +id: Nat) -> Bool:
  +n = B.node(w, id)
  Bool.and(B.computed(R.Node.kind(n)), Bool.and(B.has(R.Node.config(n), K.CONFIG_AUTO_DISPOSE()),
    Bool.and(Nat.is_eq(R.Node.subs(n), 0n), Bool.and(Bool.not(B.has(R.Node.flags(n), K.REACTIVE_ZOMBIE())), Bool.not(B.has(R.Node.status(n), K.STATUS_PENDING()))))))
def releaseIfSettledUnobserved(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, releasable(w, id),
    _ => B.choose(~R.World, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_IN_HEAP()),
      _ => B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(R.Node.flags(B.node(w, id)), K.REACTIVE_RELEASE_AFTER()))),
      _ => O.unobserved(w, id)), _ => w)

# Source nested settlePendingSource owns fresh visited/released/scheduled
# locals. Its return task restores the enclosing walk's private locals.
def settlementTasks(w: R.World, +id: Nat, source: Nat) -> List<&2, Task>:
  [Walk{R.Node.subs(B.node(w, id)), id, source}, Release{0n}, End{}]

def stageMarkMask() -> U32:
  B.set(B.set(K.CONFIG_REDERIVE(), K.CONFIG_STAGED_ERROR()), U32.shln(K.EFFECT_TRACKED(), 23n))

# The three source stores before the nested settle call, kept as one segment.
def stageMarkPrefix(+w: R.World, +id: Nat, root: Nat) -> R.World:
  +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Node.pending(B.node(w, root))))
  +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), K.CONFIG_STAGED_ERROR())))
  Intake.queuePendingNode(w, id)

# verdict.ts:stageMark walks actual deps: an error-boundary output does not
# forward a staging merely because the source walk can reach its reader.
def stagedDependencyLoop(fuel: Nat, +w: R.World, +edge: Nat) -> B.Bundle<R.World, Bool>:
  match fuel:
    case 0n: B.Bundle{R.World.with_fault(w, R.Exhausted{}), False{}}
    case 1n+p:
      B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(edge, 0n), _ => B.Bundle{w, False{}},
        _ => B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.config(B.node(w, R.Link.dep(B.link(w, edge)))), K.CONFIG_STAGED_ERROR()),
          _ => B.Bundle{w, True{}}, _ => stagedDependencyLoop(p, w, R.Link.nextDep(B.link(w, edge)))))

def stagedDependency(+w: R.World, id: Nat) -> B.Bundle<R.World, Bool>:
  stagedDependencyLoop(B.budget(w), w, R.Node.deps(B.node(w, id)))

def stageMark(+w: R.World, +tasks: List<&2, Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat) -> Machine:
  +eligible = Bool.and(B.has(R.Node.config(B.node(w, root)), K.CONFIG_STAGED_ERROR()), Bool.not(B.has(R.Node.config(B.node(w, id)), stageMarkMask())))
  B.choose(~Machine, eligible,
    _ =>
      +dep = stagedDependency(w, id)
      +w = B.first(R.World, Bool, dep)
      B.choose(~Machine, Bool.and(B.ok(w), B.second(R.World, Bool, dep)),
        _ =>
          +w = stageMarkPrefix(w, id, root)
          # No store family exists in the admitted non-store grammar.
          +w = B.first(R.World, Bool, P.removePendingSource(w, id, id))
          Machine{w, B.append(Task, settlementTasks(w, id, id), RestoreSettlement{visited, released, scheduled} <> tasks), [], [], False{}},
        _ => Machine{w, tasks, visited, released, scheduled}),
    _ => Machine{w, tasks, visited, released, scheduled})

# Early return deliberately does NOT add to visited. A later branch may retire
# another carrier and must be free to revisit this same converging node.
def skip(+w: R.World, +tasks: List<&2, Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat) -> Machine:
  B.choose(~Machine, B.has(R.Node.config(B.node(w, id)), K.CONFIG_VERDICT()),
    _ => Machine{H.enqueueSub(w, id), tasks, visited, released, scheduled},
    _ => stageMark(w, tasks, visited, released, scheduled, id, root))

# settlePendingSource's settled-node status block, in source mutation order.
# These named segments share the original function's locals; no task is added.
def settledStatus(+w: R.World, +id: Nat, +remaining: Nat, +errored: Bool) -> R.World:
  +w = B.choose(~R.World, Nat.is_ne(remaining, 0n),
    _ => B.choose(~R.World, errored, _ => w, _ => P.setPendingError(w, id, remaining, R.Undefined{})),
    _ =>
      +w = B.store_node(w, id, R.Node.with_status(B.node(w, id), B.clear(R.Node.status(B.node(w, id)), K.STATUS_PENDING())))
      +w = B.choose(~R.World, errored, _ => w, _ => P.setPendingError(w, id, 0n, R.Undefined{}))
      B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), _ => X.joinNode(w, id), _ => w))
  w

# settled-node enqueue/unblock/release-list tail. Queueing owner release is
# still deferred until after live dependent traversal.
def settledTailPrefix(+w: R.World, tasks: List<&2, Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, source: Nat, +last: Bool) -> Machine:
  +blocked = Bool.and(last, B.truth(B.selected(R.NodeExtension.blocked(B.extension(w, id)), R.Undefined{})))
  +w = B.choose(~R.World, Bool.and(B.ok(w), blocked), _ => H.enqueueSub(w, id), _ => w)
  +w = B.choose(~R.World, Bool.and(B.ok(w), Bool.and(last, Nat.is_ne(R.Node.x(B.node(w, id)), 0n))),
    _ => B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{False{}}})), _ => w)
  +released = B.choose(~List<&2, Nat>, Bool.and(B.ok(w), Bool.and(last, Bool.and(Nat.is_eq(R.Node.subs(B.node(w, id)), 0n), B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE())))),
    _ => B.append(Nat, released, [id]), _ => released)
  +ending = {Descend{id, root, source} <> tasks : List<&2, Task>}
  +scheduled = Bool.or(scheduled, blocked)
  Machine{w,ending,visited,released,scheduled}

# Source return point immediately before stageMark; no machine step is added.
def stageSettled(last: Bool,machine: Machine,+id: Nat,+root: Nat) -> Machine:
  match machine:
    case Machine{+w,+tasks,+visited,+released,+scheduled}:
      B.choose(~Machine,Bool.and(B.ok(w),last),_=>stageMark(w,tasks,visited,released,scheduled,id,root),_=>Machine{w,tasks,visited,released,scheduled})

def settledTail(w: R.World,tasks: List<&2,Task>,visited: List<&2,Nat>,released: List<&2,Nat>,scheduled: Bool,+id: Nat,+root: Nat,source: Nat,+last: Bool) -> Machine:
  stageSettled(last,settledTailPrefix(w,tasks,visited,released,scheduled,id,root,source,last),id,root)

def settled(+w: R.World, tasks: List<&2, Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, root: Nat, source: Nat) -> Machine:
  +w = B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w)))
  +remaining = B.get(Nat, P.items(B.pendingSources(w, id)), 0n, 0n)
  +errored = B.has(R.Node.status(B.node(w, id)), K.STATUS_ERROR())
  +w = settledStatus(w, id, remaining, errored)
  settledTail(w, tasks, visited, released, scheduled, id, root, source, Nat.is_eq(remaining, 0n))

def visitRemoved(+w: R.World, +tasks: List<&2, Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, +source: Nat) -> Machine:
  +pair = P.removePendingSource(w, id, source)
  +w = B.first(R.World, Bool, pair)
  B.choose(~Machine, B.second(R.World, Bool, pair),
    _ => settled(w, tasks, visited, released, scheduled, id, root, source),
    _ => skip(w, tasks, visited, released, scheduled, id, root))

def descended(w: R.World, +tasks: List<&2, Task>, +released: List<&2, Nat>, +scheduled: Bool, root: Nat, source: Nat, result: Walk.After) -> Machine:
  match result:
    case Walk.Descend{visited, edge}: Machine{w, Walk{edge, root, source} <> tasks, visited, released, scheduled}
    case Walk.Stopped{visited}: Machine{w, tasks, visited, released, scheduled}

def collected(w: R.World, +tasks: List<&2, Task>, +released: List<&2, Nat>, +scheduled: Bool, result: Walk.After) -> Machine:
  match result:
    case Walk.Descend{visited, edge}: Machine{w, CollectWalk{edge} <> tasks, visited, released, scheduled}
    case Walk.Stopped{visited}: Machine{w, tasks, visited, released, scheduled}

# Callback-free traversal segments, shared with core's suspending owner driver.
# Release is intercepted by each caller before entering this dispatcher.
def advance(+w: R.World, tasks: List<&2, Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool) -> Machine:
  match tasks:
    case Nil{}:
      Machine{w, [], visited, released, scheduled}
    case Visit{+id, +root, +source} <> +rest:
      B.choose(~Machine, B.contains(visited, id), _ => skip(w, rest, visited, released, scheduled, id, root),
        _ =>
          +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_ne(source, root), _ => P.retryReaches(w, id, source), _ => B.Bundle{w, False{}})
          +w = B.first(R.World, Bool, pair)
          B.choose(~Machine, B.second(R.World, Bool, pair), _ => skip(w, rest, visited, released, scheduled, id, root),
            _ => visitRemoved(w, rest, visited, released, scheduled, id, root, source)))
    case Descend{+id, root, source} <> +rest:
      descended(w, rest, released, scheduled, root, source, Walk.after(w, visited, id, False{}, False{}))
    case Walk{+edge, +root, +source} <> +rest:
      B.choose(~Machine, Nat.is_eq(edge, 0n), _ => Machine{w, rest, visited, released, scheduled},
        _ => Machine{w, Visit{R.Link.sub(B.link(w, edge)), root, source} <> Next{edge, root, source} <> rest, visited, released, scheduled})
    case Next{+edge, root, source} <> rest:
      Machine{w, Walk{Walk.next(w, edge), root, source} <> rest, visited, released, scheduled}
    case Collect{+id} <> +rest:
      B.choose(~Machine, B.contains(visited, id), _ => Machine{w, rest, visited, released, scheduled},
        _ =>
          released = B.choose(~List<&2, Nat>, Bool.and(Nat.is_eq(R.Node.subs(B.node(w, id)), 0n), B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE())),
            _ => B.append(Nat, released, [id]), _ => released)
          collected(w, rest, released, scheduled, Walk.after(w, visited, id, False{}, False{})))
    case CollectWalk{+edge} <> +rest:
      B.choose(~Machine, Nat.is_eq(edge, 0n), _ => Machine{w, rest, visited, released, scheduled},
        _ => Machine{w, Collect{R.Link.sub(B.link(w, edge))} <> CollectNext{edge} <> rest, visited, released, scheduled})
    case CollectNext{+edge} <> rest:
      Machine{w, CollectWalk{Walk.next(w, edge)} <> rest, visited, released, scheduled}
    case RestoreSettlement{outerVisited, outerReleased, outerScheduled} <> rest:
      Machine{w, rest, outerVisited, outerReleased, outerScheduled}
    case End{} <> rest:
      Machine{B.choose(~R.World, scheduled, _ => B.schedule(w), _ => w), rest, visited, released, scheduled}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), [], visited, released, scheduled}

def dispatch(+w: R.World, tasks: List<&2, Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool) -> Machine:
  match tasks:
    case Release{+index} <> +rest:
      B.choose(~Machine, Nat.is_ge(index, B.length(Nat, released)), _ => Machine{w, rest, visited, released, scheduled},
        _ => Machine{releaseIfSettledUnobserved(w, B.get(Nat, released, index, 0n)), Release{1n+index} <> rest, visited, released, scheduled})
    case other:
      advance(w, other, visited, released, scheduled)

def run(fuel: Nat, m: Machine) -> R.World:
  match fuel m:
    case _ Machine{w, Nil{}, visited, released, scheduled}:
      w
    case 0n Machine{w, tasks, visited, released, scheduled}:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+p Machine{+w, +tasks, +visited, +released, +scheduled}:
      B.choose(~R.World, B.ok(w), _ => run(p, dispatch(w, tasks, visited, released, scheduled)), _ => w)

def beginSettlement(+w: R.World, +id: Nat, +source: Nat) -> Machine:
  +w = B.first(R.World, Bool, P.removePendingSource(w, id, source))
  Machine{w, settlementTasks(w, id, source), [], [], False{}}

def settlePendingSource(+w: R.World, +id: Nat, +source: Nat) -> R.World:
  # Each newly marked node nests at most one walk: STAGED_ERROR closes that
  # branch before recursion. For callback-free fixed arenas, at most N+1 walks
  # each visit <=N nodes and <=E live edges. This is runtime traversal fuel,
  # separate from the unchanged independent type checker's reduction budget.
  +budget = B.budget(w)
  fuel = B.choose(~Nat, B.has(R.Node.config(B.node(w, id)), K.CONFIG_STAGED_ERROR()), _ => Nat.mul(16n, Nat.mul(budget, 1n+budget)), _ => Nat.mul(16n, budget))
  run(fuel, beginSettlement(w, id, source))

def releaseSettledDependents(+w: R.World, +id: Nat) -> R.World:
  run(Nat.mul(16n, B.budget(w)), Machine{w, [CollectWalk{R.Node.subs(B.node(w, id))}, Release{0n}], [], [], False{}})

def beginReleaseSettledDependents(+w: R.World, id: Nat) -> Machine:
  Machine{w, [CollectWalk{R.Node.subs(B.node(w, id))}, Release{0n}], [], [], False{}}

# async.ts:landStatus (private): only self retires when other inputs still pend.
def landStatus(+w: R.World, +id: Nat, +clearUninitialized: Bool) -> R.World:
  +hadSources = A.hasSources(B.pendingSources(w, id))
  +w = B.choose(~R.World, hadSources, _ => B.first(R.World, Bool, P.removePendingSource(w, id, id)), _ => w)
  +remaining = B.get(Nat, P.items(B.pendingSources(w, id)), 0n, 0n)
  B.choose(~R.World, Nat.is_ne(remaining, 0n),
    _ =>
      +w = B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{False{}}}))
      +w = B.choose(~R.World, clearUninitialized, _ => B.store_node(w, id, R.Node.with_status(B.node(w, id), K.STATUS_PENDING())), _ => w)
      P.setPendingError(w, id, remaining, R.Undefined{}),
    _ => A.clearStatus(w, id, clearUninitialized))

# async.ts:stageError preserves StatusError wrappers; a NotReady payload passed
# explicitly to this helper is wrapped, unlike notifyStatus's error arm.
def stageWrap(w: R.World, id: Nat, error: R.Value) -> B.Bundle<R.World, R.Value>:
  match error:
    case R.StatusFailure{identity, source, cause, message}:
      B.Bundle{w, R.StatusFailure{identity, source, cause, message}}
    case other:
      A.statusError(w, id, other)

# next@d682022c: source excludes projection derives (el.fam) from the in-pass
# staged-read arm (#4195). Projection-family nodes cannot be constructed in
# this admitted profile; the missing active family branch remains unported.
def beginStageError(+w: R.World, +id: Nat, error: R.Value, inPass: Bool) -> B.Bundle<R.World, Bool>:
  stage = Bool.and(Bool.or(B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()),
    Bool.and(inPass, Bool.and(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_STAGED_READ()), R.World.running(w)))), Nat.is_eq(R.World.passLane(w), 0n))
  B.choose(~B.Bundle<R.World, Bool>, stage,
    _ =>
      +w = P.clearPendingSources(w, id)
      +w = B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
        _ => B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{False{}}})), _ => w)
      +w = B.store_node(w, id, R.Node.with_status(B.node(w, id), U32.and(R.Node.status(B.node(w, id)), B.set(K.STATUS_ERROR(), K.STATUS_UNINITIALIZED()))))
      +w = B.choose(~R.World, B.has(R.Node.status(B.node(w, id)), K.STATUS_ERROR()), _ => w, _ => P.setPendingError(w, id, 0n, R.Undefined{}))
      +pair = stageWrap(w, id, error)
      +w = B.first(R.World, R.Value, pair)
      +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{B.second(R.World, R.Value, pair)}))
      +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), B.set(K.CONFIG_STAGED(), K.CONFIG_STAGED_ERROR()))))
      B.Bundle{w, True{}},
    _ => B.Bundle{w, False{}})

def stageError(+w: R.World, +id: Nat, error: R.Value, inPass: Bool) -> B.Bundle<R.World, Bool>:
  +pair = beginStageError(w, id, error, inPass)
  +w = B.first(R.World, Bool, pair)
  +staged = B.second(R.World, Bool, pair)
  +w = B.choose(~R.World, staged, _ => settlePendingSource(w, id, id), _ => w)
  B.Bundle{B.choose(~R.World, Bool.and(B.ok(w), staged), _ => B.schedule(w), _ => w), staged}
