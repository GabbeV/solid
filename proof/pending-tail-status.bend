# The actual enqueue/unblock/release-list tail does not change any status word.
# Heap exhaustion is admitted; successful scheduling/release is not asserted.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending.bend as Q
import ../runtime/heap.bend as H
import ./node-status-operations.bend as Frame
import ./heap-status-frame.bend as Heap


def world(machine: Q.Machine) -> R.World:
  match machine:
    case Q.Machine{w,tasks,visited,released,scheduled}: w

def unblock(+w: R.World,+id: Nat,+last: Bool) -> R.World:
  B.choose(~R.World,Bool.and(B.ok(w),Bool.and(last,Nat.is_ne(R.Node.x(B.node(w,id)),0n))),_=>B.store_extension(w,id,R.NodeExtension.with_blocked(B.extension(w,id),R.Present{R.Boolean{False{}}})),_=>w)

def unblockFrame(+w: R.World,+id: Nat,+last: Bool) -> {Frame.observe(unblock(w,id,last)) == Frame.observe(w) : List<&2,U32>}:
  Frame.choice(Bool.and(B.ok(w),Bool.and(last,Nat.is_ne(R.Node.x(B.node(w,id)),0n))),w,B.store_extension(w,id,R.NodeExtension.with_blocked(B.extension(w,id),R.Present{R.Boolean{False{}}})),w,Frame.storeExtension(w,id,R.NodeExtension.with_blocked(B.extension(w,id),R.Present{R.Boolean{False{}}})),{==})

def tail(+w: R.World,+tasks: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+scheduled: Bool,+id: Nat,+root: Nat,+source: Nat,+last: Bool) -> {Frame.observe(world(Q.settledTail(w,tasks,visited,released,scheduled,id,root,source,last))) == Frame.observe(w) : List<&2,U32>}:
  +blocked = Bool.and(last,B.truth(B.selected(R.NodeExtension.blocked(B.extension(w,id)),R.Undefined{})))
  +next = B.choose(~R.World,Bool.and(B.ok(w),blocked),_=>H.enqueueSub(w,id),_=>w)
  Frame.compose(w,next,world(Q.settledTail(w,tasks,visited,released,scheduled,id,root,source,last)),unblockFrame(next,id,last),Frame.choice(Bool.and(B.ok(w),blocked),w,H.enqueueSub(w,id),w,Heap.enqueue(w,id),{==}))
