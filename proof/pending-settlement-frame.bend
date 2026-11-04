# Actual callback-free source settlement traversal. This observation is committed
# storage/tree/trace, not a promise that source status, lists, or queues are fixed.
# Owner release/callback execution is an explicit separate boundary.
import Base
import ../runtime/pending-queue.bend as Intake
import ../runtime/read-state.bend as Read
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/pending.bend as Q
import ../runtime/heap.bend as H
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ./committed-storage-frame.bend as Frame
import ./pending-source-committed-frame.bend as Source
import ./heap-committed-frame.bend as Heap
import ./setter-committed-frame.bend as Setter

def world(machine: Q.Machine) -> R.World:
  match machine:
    case Q.Machine{w, tasks, visited, released, scheduled}: w

def choice(+condition: Bool, +w: R.World, +left: Q.Machine, +right: Q.Machine,
  leftFrame: {Frame.observe(world(left)) == Frame.observe(w) : Frame.View},
  rightFrame: {Frame.observe(world(right)) == Frame.observe(w) : Frame.View}) ->
  {Frame.observe(world(B.choose(~Q.Machine, condition, _ => left, _ => right))) == Frame.observe(w) : Frame.View}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

def retry(+fuel: Nat, +w: R.World, +edge: Nat, +source: Nat) ->
  {Frame.observe(B.first(R.World, Bool, P.retryLoop(fuel, w, edge, source))) == Frame.observe(w) : Frame.View}:
  match fuel:
    case 0n:
      Frame.choice(Nat.is_eq(edge, 0n), w, w, R.World.with_fault(w, R.Exhausted{}), {==}, Frame.worldFault(w, R.Exhausted{}))
    case 1n+p:
      +dep = R.Link.dep(B.link(w, edge))
      +pair = B.choose(~B.Bundle<R.World, Bool>, Bool.or(Nat.is_eq(dep, source), P.hasSource(w, dep, source)), _ => B.Bundle{w, True{}}, _ => P.retryLoop(p, w, R.Link.nextDep(B.link(w, edge)), source))
      Frame.firstBoolChoice(Nat.is_eq(edge, 0n), w, B.Bundle{w, False{}}, pair, {==},
        Frame.firstBoolChoice(Bool.or(Nat.is_eq(dep, source), P.hasSource(w, dep, source)), w, B.Bundle{w, True{}}, P.retryLoop(p, w, R.Link.nextDep(B.link(w, edge)), source), {==}, retry(p, w, R.Link.nextDep(B.link(w, edge)), source)))

# queuePendingNode changes neither this observation nor the source graph.
def queue(+w: R.World, +id: Nat) -> {Frame.observe(Intake.queuePendingNode(w, id)) == Frame.observe(w) : Frame.View}:
  +next = R.World.with_pendingNodes(w, B.append(Nat, R.World.pendingNodes(w), [id]))
  Frame.compose(w, next, Intake.queuePendingNode(w, id), Frame.choice(Bool.not(R.World.running(next)), next, Read.markUnflushedStaged(next), next, Frame.worldUnflushedStaged(next, True{}), {==}), Frame.worldPendingNodes(w, B.append(Nat, R.World.pendingNodes(w), [id])))

def stagePrefix(+w: R.World, +id: Nat, +root: Nat) -> {Frame.observe(Q.stageMarkPrefix(w, id, root)) == Frame.observe(w) : Frame.View}:
  +staged = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Node.pending(B.node(w, root))))
  +marked = B.store_node(staged, id, R.Node.with_config(B.node(staged, id), B.set(R.Node.config(B.node(staged, id)), K.CONFIG_STAGED_ERROR())))
  Frame.compose(w, staged, Q.stageMarkPrefix(w, id, root), Frame.compose(staged, marked, Q.stageMarkPrefix(w, id, root), queue(marked, id), Frame.config(staged, id, B.set(R.Node.config(B.node(staged, id)), K.CONFIG_STAGED_ERROR()))), Frame.pending(w, id, R.Node.pending(B.node(w, root))))

# The new source dep scan changes only failure metadata, even on exhaustion.
def stagedDependency(+fuel: Nat,+w: R.World,+edge: Nat) ->
  {Frame.observe(B.first(R.World,Bool,Q.stagedDependencyLoop(fuel,w,edge))) == Frame.observe(w) : Frame.View}:
  match fuel:
    case 0n: Frame.worldFault(w,R.Exhausted{})
    case 1n+p:
      +test = B.has(R.Node.config(B.node(w,R.Link.dep(B.link(w,edge)))),K.CONFIG_STAGED_ERROR())
      Frame.firstBoolChoice(Nat.is_eq(edge,0n),w,B.Bundle{w,False{}},B.choose(~B.Bundle<R.World,Bool>,test,_=>B.Bundle{w,True{}},_=>Q.stagedDependencyLoop(p,w,R.Link.nextDep(B.link(w,edge)))),{==},
        Frame.firstBoolChoice(test,w,B.Bundle{w,True{}},Q.stagedDependencyLoop(p,w,R.Link.nextDep(B.link(w,edge))),{==},stagedDependency(p,w,R.Link.nextDep(B.link(w,edge)))))

def stageMark(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat) -> {Frame.observe(world(Q.stageMark(w, tasks, visited, released, scheduled, id, root))) == Frame.observe(w) : Frame.View}:
  +dep = Q.stagedDependency(w,id)
  +scanned = B.first(R.World,Bool,dep)
  +prefix = Q.stageMarkPrefix(scanned, id, root)
  +next = B.first(R.World, Bool, P.removePendingSource(prefix, id, id))
  +after = {Q.Machine{next, B.append(Q.Task, Q.settlementTasks(next, id, id), Q.RestoreSettlement{visited, released, scheduled} <> tasks), [], [], False{}} : Q.Machine}
  +body = B.choose(~Q.Machine,Bool.and(B.ok(scanned),B.second(R.World,Bool,dep)),_=>after,_=>Q.Machine{scanned,tasks,visited,released,scheduled})
  +bodyFrame = Frame.compose(w,scanned,world(body),
    choice(Bool.and(B.ok(scanned),B.second(R.World,Bool,dep)),scanned,after,Q.Machine{scanned,tasks,visited,released,scheduled},
      Frame.compose(scanned,prefix,next,Source.remove(prefix, id, id),stagePrefix(scanned,id,root)),{==}),
    stagedDependency(B.budget(w),w,R.Node.deps(B.node(w,id))))
  choice(Bool.and(B.has(R.Node.config(B.node(w,root)),K.CONFIG_STAGED_ERROR()),Bool.not(B.has(R.Node.config(B.node(w,id)),Q.stageMarkMask()))),w,body,Q.Machine{w,tasks,visited,released,scheduled},bodyFrame,{==})

def skip(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat) ->
  {Frame.observe(world(Q.skip(w, tasks, visited, released, scheduled, id, root))) == Frame.observe(w) : Frame.View}:
  choice(B.has(R.Node.config(B.node(w,id)),K.CONFIG_VERDICT()),w,Q.Machine{H.enqueueSub(w,id),tasks,visited,released,scheduled},Q.stageMark(w,tasks,visited,released,scheduled,id,root),Heap.enqueue(w,id),stageMark(w,tasks,visited,released,scheduled,id,root))

# Source settled(): clear the status only for the last carrier, then possibly
# join the existing transaction. Joining is bookkeeping; it does not publish.
def clear(+w: R.World, +id: Nat, +errored: Bool) -> R.World:
  +w = B.store_node(w, id, R.Node.with_status(B.node(w, id), B.clear(R.Node.status(B.node(w, id)), K.STATUS_PENDING())))
  +w = B.choose(~R.World, errored, _ => w, _ => P.setPendingError(w, id, 0n, R.Undefined{}))
  B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), _ => X.joinNode(w, id), _ => w)

def clearFrame(+w: R.World, +id: Nat, +errored: Bool) ->
  {Frame.observe(clear(w, id, errored)) == Frame.observe(w) : Frame.View}:
  +status = B.clear(R.Node.status(B.node(w, id)), K.STATUS_PENDING())
  +first = B.store_node(w, id, R.Node.with_status(B.node(w, id), status))
  +second = B.choose(~R.World, errored, _ => first, _ => P.setPendingError(first, id, 0n, R.Undefined{}))
  Frame.compose(w, first, clear(w, id, errored),
    Frame.compose(first, second, clear(w, id, errored),
      Frame.choice(B.has(R.Node.config(B.node(second, id)), K.CONFIG_HELD()), second, X.joinNode(second, id), second, Setter.joinNode(second, id), {==}),
      Frame.choice(errored, first, first, P.setPendingError(first, id, 0n, R.Undefined{}), {==}, Source.setError(first, id, 0n, R.Undefined{}))), Frame.status(w, id, status))

def status(+w: R.World, +id: Nat, +remaining: Nat, +errored: Bool) -> R.World:
  B.choose(~R.World, Nat.is_ne(remaining, 0n), _ => B.choose(~R.World, errored, _ => w, _ => P.setPendingError(w, id, remaining, R.Undefined{})), _ => clear(w, id, errored))

def statusFrame(+w: R.World, +id: Nat, +remaining: Nat, +errored: Bool) ->
  {Frame.observe(status(w, id, remaining, errored)) == Frame.observe(w) : Frame.View}:
  Frame.choice(Nat.is_ne(remaining, 0n), w, B.choose(~R.World, errored, _ => w, _ => P.setPendingError(w, id, remaining, R.Undefined{})), clear(w, id, errored),
    Frame.choice(errored, w, w, P.setPendingError(w, id, remaining, R.Undefined{}), {==}, Source.setError(w, id, remaining, R.Undefined{})), clearFrame(w, id, errored))

def unblock(+w: R.World, +id: Nat, +last: Bool) -> R.World:
  B.choose(~R.World, Bool.and(B.ok(w), Bool.and(last, Nat.is_ne(R.Node.x(B.node(w, id)), 0n))),
    _ => B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{False{}}})), _ => w)

def unblockFrame(+w: R.World, +id: Nat, +last: Bool) ->
  {Frame.observe(unblock(w, id, last)) == Frame.observe(w) : Frame.View}:
  +record = R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{False{}}})
  Frame.choice(Bool.and(B.ok(w), Bool.and(last, Nat.is_ne(R.Node.x(B.node(w, id)), 0n))), w, B.store_extension(w, id, record), w, Frame.storeExtension(w, id, record), {==})

def statusExact(w: R.World, id: Nat, remaining: Nat, errored: Bool) ->
  {Q.settledStatus(w, id, remaining, errored) == status(w, id, remaining, errored) : R.World}:
  {==}

def actualStatus(+w: R.World, +id: Nat, +remaining: Nat, +errored: Bool) ->
  {Frame.observe(Q.settledStatus(w, id, remaining, errored)) == Frame.observe(w) : Frame.View}:
  Equal.trans(Frame.View, Frame.observe(Q.settledStatus(w, id, remaining, errored)), Frame.observe(status(w, id, remaining, errored)), Frame.observe(w), Equal.cong(R.World, Frame.View, next => Frame.observe(next), Q.settledStatus(w, id, remaining, errored), status(w, id, remaining, errored), statusExact(w, id, remaining, errored)), statusFrame(w, id, remaining, errored))

def tailPrefix(+w: R.World,+tasks: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+scheduled: Bool,+id: Nat,+root: Nat,+source: Nat,+last: Bool) ->
  {Frame.observe(world(Q.settledTailPrefix(w,tasks,visited,released,scheduled,id,root,source,last))) == Frame.observe(w) : Frame.View}:
  +blocked = Bool.and(last,B.truth(B.selected(R.NodeExtension.blocked(B.extension(w,id)),R.Undefined{})))
  +queued = B.choose(~R.World,Bool.and(B.ok(w),blocked),_=>H.enqueueSub(w,id),_=>w)
  Frame.compose(w,queued,unblock(queued,id,last),unblockFrame(queued,id,last),Frame.choice(Bool.and(B.ok(w),blocked),w,H.enqueueSub(w,id),w,Heap.enqueue(w,id),{==}))

def tail(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, +source: Nat, +last: Bool) ->
  {Frame.observe(world(Q.settledTail(w, tasks, visited, released, scheduled, id, root, source, last))) == Frame.observe(w) : Frame.View}:
  +blocked = Bool.and(last,B.truth(B.selected(R.NodeExtension.blocked(B.extension(w,id)),R.Undefined{})))
  +queued = B.choose(~R.World,Bool.and(B.ok(w),blocked),_=>H.enqueueSub(w,id),_=>w)
  +next = unblock(queued,id,last)
  +newReleased = B.choose(~List<&2,Nat>,Bool.and(B.ok(next),Bool.and(last,Bool.and(Nat.is_eq(R.Node.subs(B.node(next,id)),0n),B.has(R.Node.config(B.node(next,id)),K.CONFIG_AUTO_DISPOSE())))),_=>B.append(Nat,released,[id]),_=>released)
  +newScheduled = Bool.or(scheduled,blocked)
  +ending = {Q.Descend{id,root,source} <> tasks : List<&2,Q.Task>}
  +body = B.choose(~Q.Machine,Bool.and(B.ok(next),last),_=>Q.stageMark(next,ending,visited,newReleased,newScheduled,id,root),_=>Q.Machine{next,ending,visited,newReleased,newScheduled})
  Frame.compose(w,queued,world(body),
    Frame.compose(queued,next,world(body),choice(Bool.and(B.ok(next),last),next,Q.stageMark(next,ending,visited,newReleased,newScheduled,id,root),Q.Machine{next,ending,visited,newReleased,newScheduled},stageMark(next,ending,visited,newReleased,newScheduled,id,root),{==}),unblockFrame(queued,id,last)),
    Frame.choice(Bool.and(B.ok(w),blocked),w,H.enqueueSub(w,id),w,Heap.enqueue(w,id),{==}))

def settled(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, +source: Nat) ->
  {Frame.observe(world(Q.settled(w, tasks, visited, released, scheduled, id, root, source))) == Frame.observe(w) : Frame.View}:
  +timed = B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w)))
  +remaining = B.get(Nat, P.items(B.pendingSources(timed, id)), 0n, 0n)
  +errored = B.has(R.Node.status(B.node(timed, id)), K.STATUS_ERROR())
  +statused = Q.settledStatus(timed, id, remaining, errored)
  Frame.compose(w, timed, world(Q.settled(w, tasks, visited, released, scheduled, id, root, source)),
    Frame.compose(timed, statused, world(Q.settled(w, tasks, visited, released, scheduled, id, root, source)), tail(statused, tasks, visited, released, scheduled, id, root, source, Nat.is_eq(remaining, 0n)), actualStatus(timed, id, remaining, errored)), Frame.time(w, id, R.World.clock(w)))

def removed(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, +source: Nat) ->
  {Frame.observe(world(Q.visitRemoved(w, tasks, visited, released, scheduled, id, root, source))) == Frame.observe(w) : Frame.View}:
  +pair = P.removePendingSource(w, id, source)
  +next = B.first(R.World, Bool, pair)
  Frame.compose(w, next, world(Q.visitRemoved(w, tasks, visited, released, scheduled, id, root, source)),
    choice(B.second(R.World, Bool, pair), next, Q.settled(next, tasks, visited, released, scheduled, id, root, source), Q.skip(next, tasks, visited, released, scheduled, id, root), settled(next, tasks, visited, released, scheduled, id, root, source), skip(next, tasks, visited, released, scheduled, id, root)), Source.remove(w, id, source))

# The real dependency retry scan can fault on a malformed/exhausted graph. The
# observation frame still holds; this root does not assert successful traversal.
def visit(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, +source: Nat) ->
  {Frame.observe(world(Q.advance(w, Q.Visit{id, root, source} <> tasks, visited, released, scheduled))) == Frame.observe(w) : Frame.View}:
  +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_ne(source, root), _ => P.retryReaches(w, id, source), _ => B.Bundle{w, False{}})
  +next = B.first(R.World, Bool, pair)
  +reached = B.choose(~Q.Machine, B.second(R.World, Bool, pair), _ => Q.skip(next, tasks, visited, released, scheduled, id, root), _ => Q.visitRemoved(next, tasks, visited, released, scheduled, id, root, source))
  choice(B.contains(visited, id), w, Q.skip(w, tasks, visited, released, scheduled, id, root), reached, skip(w, tasks, visited, released, scheduled, id, root),
    Frame.compose(w, next, world(reached), choice(B.second(R.World, Bool, pair), next, Q.skip(next, tasks, visited, released, scheduled, id, root), Q.visitRemoved(next, tasks, visited, released, scheduled, id, root, source), skip(next, tasks, visited, released, scheduled, id, root), removed(next, tasks, visited, released, scheduled, id, root, source)),
      Frame.firstBoolChoice(Nat.is_ne(source, root), w, P.retryReaches(w, id, source), B.Bundle{w, False{}}, retry(B.budget(w), w, R.Node.deps(B.node(w, id)), source), {==})))

def advance(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool) ->
  {Frame.observe(world(Q.advance(w, tasks, visited, released, scheduled))) == Frame.observe(w) : Frame.View}:
  match tasks:
    case Nil{}: {==}
    case Q.Visit{+id, +root, +source} <> +rest: visit(w, rest, visited, released, scheduled, id, root, source)
    case Q.Walk{+edge, +root, +source} <> +rest:
      choice(Nat.is_eq(edge, 0n), w, Q.Machine{w, rest, visited, released, scheduled}, Q.Machine{w, Q.Visit{R.Link.sub(B.link(w, edge)), root, source} <> Q.Next{edge, root, source} <> rest, visited, released, scheduled}, {==}, {==})
    case Q.Next{edge, root, source} <> rest: {==}
    case Q.Descend{id,root,source} <> rest: {==}
    case Q.Collect{+id} <> +rest:
      choice(B.contains(visited, id), w, Q.Machine{w, rest, visited, released, scheduled},
        Q.Machine{w, Q.CollectWalk{R.Node.subs(B.node(w, id))} <> rest, id <> visited, B.choose(~List<&2, Nat>, Bool.and(Nat.is_eq(R.Node.subs(B.node(w, id)), 0n), B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE())), _ => B.append(Nat, released, [id]), _ => released), scheduled}, {==}, {==})
    case Q.CollectWalk{+edge} <> +rest:
      choice(Nat.is_eq(edge, 0n), w, Q.Machine{w, rest, visited, released, scheduled}, Q.Machine{w, Q.Collect{R.Link.sub(B.link(w, edge))} <> Q.CollectNext{edge} <> rest, visited, released, scheduled}, {==}, {==})
    case Q.CollectNext{edge} <> rest: {==}
    case Q.RestoreSettlement{outerVisited, outerReleased, outerScheduled} <> rest: {==}
    case Q.End{} <> rest: Frame.choice(scheduled, w, B.schedule(w), w, Frame.schedule(w), {==})
    case Q.Release{index} <> rest: Frame.worldFault(w, R.TypeError{})

def begin(+w: R.World, +id: Nat, +source: Nat) ->
  {Frame.observe(world(Q.beginSettlement(w, id, source))) == Frame.observe(w) : Frame.View}:
  Source.remove(w, id, source)
