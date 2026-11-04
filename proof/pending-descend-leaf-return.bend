# rc.21 walkDependents' successful-body return: descend AFTER nested settlement.
# This adds one actual Core step before the existing empty-leaf suffix. No
# successful helper output or fault-free poststate is assumed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/pending.bend as Q
import ./owner-continuation.bend as Owner
import ./pending-leaf-return.bend as Suffix
import ./bounded-core-return.bend as Return
import ./bounded-return-frame.bend as Framed
import ./committed-storage-frame.bend as Frame
import ./core-run-prefix.bend as Driver
import ./pending-stack-history.bend as Steps

def tailTasks(+after: Bool,child: Nat,+edge: Nat,+root: Nat) -> List<&2,Q.Task>:
  B.choose(~List<&2,Q.Task>,after,_=>[Q.Descend{child,root,root},Q.Next{edge,root,root},Q.Release{0n},Q.End{}],_=>[Q.Next{edge,root,root},Q.Release{0n},Q.End{}])

def input(w: R.World,child: Nat,edge: Nat,root: Nat,visited: List<&2,Nat>,scheduled: Bool,rest: List<&2,C.Task>,stack: List<&2,R.Value>) -> C.Machine:
  Suffix.input(w,tailTasks(True{},child,edge,root),visited,scheduled,rest,stack)

def chosenInput(+w: R.World,child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,after: Bool) -> C.Machine:
  B.choose(~C.Machine,after,_=>input(w,child,edge,root,visited,scheduled,rest,stack),_=>Suffix.next(w,edge,root,visited,scheduled,rest,stack))

def chosenWorld(+w: R.World,child: Nat,edge: Nat,root: Nat,visited: List<&2,Nat>,scheduled: Bool,rest: List<&2,C.Task>,stack: List<&2,R.Value>,after: Bool) ->
  {C.world(chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after)) == w : R.World}:
  match after:
    case True{}: {==}
    case False{}: {==}

def chosenExact(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,after: Bool) ->
  {Suffix.input(w,tailTasks(after,child,edge,root),visited,scheduled,rest,stack) == chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after) : C.Machine}:
  match after:
    case True{}: {==}
    case False{}: {==}

def enters(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,healthy: {B.ok(w) == True{} : Bool},zero: {R.Node.subs(B.node(w,child)) == 0n : Nat}) ->
  {C.step(input(w,child,edge,root,visited,scheduled,rest,stack)) == Suffix.start(w,edge,root,child <> visited,scheduled,rest,stack) : C.Machine}:
  Equal.trans(C.Machine,C.step(input(w,child,edge,root,visited,scheduled,rest,stack)),C.dispatch(w,C.PendingTasks{tailTasks(True{},child,edge,root),visited,[],scheduled} <> C.AsyncWriteSchedule{} <> rest,stack),Suffix.start(w,edge,root,child <> visited,scheduled,rest,stack),
    Owner.healthyStep(w,C.PendingTasks{tailTasks(True{},child,edge,root),visited,[],scheduled},C.AsyncWriteSchedule{} <> rest,stack,healthy),
    Equal.cong(Nat,C.Machine,head=>Suffix.input(w,[Q.Walk{head,root,root},Q.Next{edge,root,root},Q.Release{0n},Q.End{}],child <> visited,scheduled,rest,stack),R.Node.subs(B.node(w,child)),0n,zero))

def fault(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+broken: {B.ok(w) == False{} : Bool}) ->
  {Steps.iterate(2n,input(w,child,edge,root,visited,scheduled,rest,stack)) == C.Machine{w,rest,stack} : C.Machine}:
  Driver.appendStep(1n,input(w,child,edge,root,visited,scheduled,rest,stack),C.Machine{w,C.AsyncWriteSchedule{} <> rest,stack},C.Machine{w,rest,stack},Suffix.faultPendingFirst(w,tailTasks(True{},child,edge,root),visited,scheduled,rest,stack,broken),Suffix.faultLast(w,rest,stack,broken))

def completeBy(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+end: {R.Link.nextSub(B.link(w,edge)) == 0n : Nat},+zero: {R.Node.subs(B.node(w,child)) == 0n : Nat},ready: Bool,known: {B.ok(w) == ready : Bool}) ->
  Return.Returned<input(w,child,edge,root,visited,scheduled,rest,stack),rest,stack,8n>:
  match ready:
    case True{}:
      Return.prepend(input(w,child,edge,root,visited,scheduled,rest,stack),Suffix.start(w,edge,root,child <> visited,scheduled,rest,stack),rest,stack,1n,7n,enters(w,child,edge,root,visited,scheduled,rest,stack,known,zero),Suffix.complete(w,edge,root,child <> visited,scheduled,rest,stack,end))
    case False{}:
      Return.ReturnedAt{2n,6n,w,{==},fault(w,child,edge,root,visited,scheduled,rest,stack,known)}

def complete(+w: R.World,child: Nat,edge: Nat,root: Nat,visited: List<&2,Nat>,scheduled: Bool,rest: List<&2,C.Task>,stack: List<&2,R.Value>,end: {R.Link.nextSub(B.link(w,edge)) == 0n : Nat},zero: {R.Node.subs(B.node(w,child)) == 0n : Nat}) ->
  Return.Returned<input(w,child,edge,root,visited,scheduled,rest,stack),rest,stack,8n>:
  completeBy(w,child,edge,root,visited,scheduled,rest,stack,end,zero,B.ok(w),{==})

def frameBy(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+end: {R.Link.nextSub(B.link(w,edge)) == 0n : Nat},+zero: {R.Node.subs(B.node(w,child)) == 0n : Nat},ready: Bool,+known: {B.ok(w) == ready : Bool}) ->
  {Frame.observe(Return.world(input(w,child,edge,root,visited,scheduled,rest,stack),rest,stack,8n,completeBy(w,child,edge,root,visited,scheduled,rest,stack,end,zero,ready,known))) == Frame.observe(w) : Frame.View}:
  match ready:
    case True{}:
      Framed.prepend(input(w,child,edge,root,visited,scheduled,rest,stack),Suffix.start(w,edge,root,child <> visited,scheduled,rest,stack),rest,stack,1n,7n,enters(w,child,edge,root,visited,scheduled,rest,stack,known,zero),Suffix.complete(w,edge,root,child <> visited,scheduled,rest,stack,end),{==},Suffix.completeFrame(w,edge,root,child <> visited,scheduled,rest,stack,end))
    case False{}: {==}

def frame(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+end: {R.Link.nextSub(B.link(w,edge)) == 0n : Nat},+zero: {R.Node.subs(B.node(w,child)) == 0n : Nat}) ->
  {Frame.observe(Return.world(input(w,child,edge,root,visited,scheduled,rest,stack),rest,stack,8n,complete(w,child,edge,root,visited,scheduled,rest,stack,end,zero))) == Frame.observe(w) : Frame.View}:
  frameBy(w,child,edge,root,visited,scheduled,rest,stack,end,zero,B.ok(w),{==})

def chosenComplete(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+end: {R.Link.nextSub(B.link(w,edge)) == 0n : Nat},+zero: {R.Node.subs(B.node(w,child)) == 0n : Nat},after: Bool) ->
  Return.Returned<chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after),rest,stack,8n>:
  match after:
    case True{}: complete(w,child,edge,root,visited,scheduled,rest,stack,end,zero)
    case False{}: Return.widen(Suffix.next(w,edge,root,visited,scheduled,rest,stack),rest,stack,7n,1n,Suffix.completeNext(w,edge,root,visited,scheduled,rest,stack,end))

def chosenFrame(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+end: {R.Link.nextSub(B.link(w,edge)) == 0n : Nat},+zero: {R.Node.subs(B.node(w,child)) == 0n : Nat},+after: Bool) ->
  {Frame.observe(Return.world(chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after),rest,stack,8n,chosenComplete(w,child,edge,root,visited,scheduled,rest,stack,end,zero,after))) == Frame.observe(w) : Frame.View}:
  match after:
    case True{}: frame(w,child,edge,root,visited,scheduled,rest,stack,end,zero)
    case False{}: Framed.widen(Suffix.next(w,edge,root,visited,scheduled,rest,stack),rest,stack,7n,1n,Suffix.completeNext(w,edge,root,visited,scheduled,rest,stack,end),Suffix.completeNextFrame(w,edge,root,visited,scheduled,rest,stack,end))

# Composition asks for the exact middle-machine observation, before reducing
# the Bool-selected choice; connect it explicitly instead of assuming a lens law.
def chosenFrameAt(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+end: {R.Link.nextSub(B.link(w,edge)) == 0n : Nat},+zero: {R.Node.subs(B.node(w,child)) == 0n : Nat},+after: Bool) ->
  {Frame.observe(Return.world(chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after),rest,stack,8n,chosenComplete(w,child,edge,root,visited,scheduled,rest,stack,end,zero,after))) == Frame.observe(C.world(chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after))) : Frame.View}:
  Equal.trans(Frame.View,Frame.observe(Return.world(chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after),rest,stack,8n,chosenComplete(w,child,edge,root,visited,scheduled,rest,stack,end,zero,after))),Frame.observe(w),Frame.observe(C.world(chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after))),chosenFrame(w,child,edge,root,visited,scheduled,rest,stack,end,zero,after),Equal.cong(R.World,Frame.View,world=>Frame.observe(world),w,C.world(chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after)),Equal.sym(R.World,C.world(chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after)),w,chosenWorld(w,child,edge,root,visited,scheduled,rest,stack,after))))
