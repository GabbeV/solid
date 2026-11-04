# The actual enqueue/unblock/release-list tail does not change any status word.
# Heap exhaustion is admitted; successful scheduling/release is not asserted.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending.bend as Q
import ../runtime/heap.bend as H
import ./node-status-operations.bend as Frame
import ./heap-status-frame.bend as Heap
import ./pending-source-status-frame.bend as Source
import ../runtime/pending-queue.bend as Intake
import ../runtime/read-state.bend as Read
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K


def world(machine: Q.Machine) -> R.World:
  match machine:
    case Q.Machine{w,tasks,visited,released,scheduled}: w

def unblock(+w: R.World,+id: Nat,+last: Bool) -> R.World:
  B.choose(~R.World,Bool.and(B.ok(w),Bool.and(last,Nat.is_ne(R.Node.x(B.node(w,id)),0n))),_=>B.store_extension(w,id,R.NodeExtension.with_blocked(B.extension(w,id),R.Present{R.Boolean{False{}}})),_=>w)

def unblockFrame(+w: R.World,+id: Nat,+last: Bool) -> {Frame.observe(unblock(w,id,last)) == Frame.observe(w) : List<&2,U32>}:
  Frame.choice(Bool.and(B.ok(w),Bool.and(last,Nat.is_ne(R.Node.x(B.node(w,id)),0n))),w,B.store_extension(w,id,R.NodeExtension.with_blocked(B.extension(w,id),R.Present{R.Boolean{False{}}})),w,Frame.storeExtension(w,id,R.NodeExtension.with_blocked(B.extension(w,id),R.Present{R.Boolean{False{}}})),{==})

def choice(+condition: Bool, +w: R.World, +left: Q.Machine, +right: Q.Machine,
  leftFrame: {Frame.observe(world(left)) == Frame.observe(w) : List<&2,U32>},
  rightFrame: {Frame.observe(world(right)) == Frame.observe(w) : List<&2,U32>}) ->
  {Frame.observe(world(B.choose(~Q.Machine, condition, _ => left, _ => right))) == Frame.observe(w) : List<&2,U32>}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

def queue(+w: R.World, +id: Nat) -> {Frame.observe(Intake.queuePendingNode(w, id)) == Frame.observe(w) : List<&2,U32>}:
  +next = R.World.with_pendingNodes(w, B.append(Nat, R.World.pendingNodes(w), [id]))
  Frame.compose(w, next, Intake.queuePendingNode(w, id), Frame.choice(Bool.not(R.World.running(next)), next, Read.markUnflushedStaged(next), next, Frame.worldUnflushedStaged(next, True{}), {==}), Frame.worldPendingNodes(w, B.append(Nat, R.World.pendingNodes(w), [id])))

def stagePrefix(+w: R.World, +id: Nat, +root: Nat) -> {Frame.observe(Q.stageMarkPrefix(w, id, root)) == Frame.observe(w) : List<&2,U32>}:
  +staged = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Node.pending(B.node(w, root))))
  +marked = B.store_node(staged, id, R.Node.with_config(B.node(staged, id), B.set(R.Node.config(B.node(staged, id)), K.CONFIG_STAGED_ERROR())))
  Frame.compose(w, staged, Q.stageMarkPrefix(w, id, root), Frame.compose(staged, marked, Q.stageMarkPrefix(w, id, root), queue(marked, id), Frame.config(staged, id, B.set(R.Node.config(B.node(staged, id)), K.CONFIG_STAGED_ERROR()))), Frame.pending(w, id, R.Node.pending(B.node(w, root))))

# The new source dep scan changes only failure metadata, even on exhaustion.
def stagedDependency(+fuel: Nat,+w: R.World,+edge: Nat) ->
  {Frame.observe(B.first(R.World,Bool,Q.stagedDependencyLoop(fuel,w,edge))) == Frame.observe(w) : List<&2,U32>}:
  match fuel:
    case 0n: Frame.worldFault(w,R.Exhausted{})
    case 1n+p:
      +test = B.has(R.Node.config(B.node(w,R.Link.dep(B.link(w,edge)))),K.CONFIG_STAGED_ERROR())
      Frame.firstBoolChoice(Nat.is_eq(edge,0n),w,B.Bundle{w,False{}},B.choose(~B.Bundle<R.World,Bool>,test,_=>B.Bundle{w,True{}},_=>Q.stagedDependencyLoop(p,w,R.Link.nextDep(B.link(w,edge)))),{==},
        Frame.firstBoolChoice(test,w,B.Bundle{w,True{}},Q.stagedDependencyLoop(p,w,R.Link.nextDep(B.link(w,edge))),{==},stagedDependency(p,w,R.Link.nextDep(B.link(w,edge)))))

def stageMark(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat) -> {Frame.observe(world(Q.stageMark(w, tasks, visited, released, scheduled, id, root))) == Frame.observe(w) : List<&2,U32>}:
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

def prefix(+w: R.World,+tasks: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+scheduled: Bool,+id: Nat,+root: Nat,+source: Nat,+last: Bool) -> {Frame.observe(world(Q.settledTailPrefix(w,tasks,visited,released,scheduled,id,root,source,last))) == Frame.observe(w) : List<&2,U32>}:
  +blocked = Bool.and(last,B.truth(B.selected(R.NodeExtension.blocked(B.extension(w,id)),R.Undefined{})))
  +next = B.choose(~R.World,Bool.and(B.ok(w),blocked),_=>H.enqueueSub(w,id),_=>w)
  Frame.compose(w,next,world(Q.settledTailPrefix(w,tasks,visited,released,scheduled,id,root,source,last)),unblockFrame(next,id,last),Frame.choice(Bool.and(B.ok(w),blocked),w,H.enqueueSub(w,id),w,Heap.enqueue(w,id),{==}))

def staged(+machine: Q.Machine,+last: Bool,+id: Nat,+root: Nat) -> {Frame.observe(world(Q.stageSettled(last,machine,id,root))) == Frame.observe(world(machine)) : List<&2,U32>}:
  match machine:
    case Q.Machine{+w,+tasks,+visited,+released,+scheduled}:
      choice(Bool.and(B.ok(w),last),w,Q.stageMark(w,tasks,visited,released,scheduled,id,root),Q.Machine{w,tasks,visited,released,scheduled},stageMark(w,tasks,visited,released,scheduled,id,root),{==})

def tail(+w: R.World,+tasks: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+scheduled: Bool,+id: Nat,+root: Nat,+source: Nat,+last: Bool) -> {Frame.observe(world(Q.settledTail(w,tasks,visited,released,scheduled,id,root,source,last))) == Frame.observe(w) : List<&2,U32>}:
  +prepared = Q.settledTailPrefix(w,tasks,visited,released,scheduled,id,root,source,last)
  Frame.compose(w,world(prepared),world(Q.stageSettled(last,prepared,id,root)),staged(prepared,last,id,root),prefix(w,tasks,visited,released,scheduled,id,root,source,last))
