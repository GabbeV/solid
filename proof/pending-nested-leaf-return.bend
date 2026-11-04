# Actual return through stageMark's nested leaf settle. The nested walk owns
# fresh private locals, then restores the enclosing walk. No callback executes
# in this empty dependent list/release list; the outer suffix stays queued.
import Base
import ./pending-descend-leaf-return.bend as Descend
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/pending.bend as Q
import ./owner-continuation.bend as Owner
import ./pending-leaf-return.bend as Suffix
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver
import ./bounded-core-return.bend as Return
import ./bounded-return-frame.bend as FramedReturn
import ./committed-storage-frame.bend as Frame

def tail(+edge: Nat,+root: Nat) -> List<&2,Q.Task>:
  [Q.Next{edge,root,root},Q.Release{0n},Q.End{}]

def tasks(+child: Nat,+edge: Nat,+root: Nat,visited: List<&2,Nat>,scheduled: Bool,+after: Bool) -> List<&2,Q.Task>:
  B.append(Q.Task,[Q.Walk{0n,child,child},Q.Release{0n},Q.End{}],Q.RestoreSettlement{visited,[],scheduled} <> Descend.tailTasks(after,child,edge,root))

def state(w: R.World,work: List<&2,Q.Task>,rest: List<&2,C.Task>,stack: List<&2,R.Value>) -> C.Machine:
  C.Machine{w,C.PendingTasks{work,[],[],False{}} <> C.AsyncWriteSchedule{} <> rest,stack}

def input(w: R.World,child: Nat,edge: Nat,root: Nat,visited: List<&2,Nat>,scheduled: Bool,rest: List<&2,C.Task>,stack: List<&2,R.Value>,+after: Bool) -> C.Machine:
  state(w,tasks(child,edge,root,visited,scheduled,after),rest,stack)

def healthyStep(+w: R.World,+work: List<&2,Q.Task>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,healthy: {B.ok(w) == True{} : Bool}) -> {C.step(state(w,work,rest,stack)) == C.dispatch(w,C.PendingTasks{work,[],[],False{}} <> C.AsyncWriteSchedule{} <> rest,stack) : C.Machine}:
  Owner.healthyStep(w,C.PendingTasks{work,[],[],False{}},C.AsyncWriteSchedule{} <> rest,stack,healthy)

def zero(+w: R.World,+child: Nat,+work: List<&2,Q.Task>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,healthy: {B.ok(w) == True{} : Bool}) -> {C.step(state(w,Q.Walk{0n,child,child} <> work,rest,stack)) == state(w,work,rest,stack) : C.Machine}:
  Equal.trans(C.Machine,C.step(state(w,Q.Walk{0n,child,child} <> work,rest,stack)),C.dispatch(w,C.PendingTasks{Q.Walk{0n,child,child} <> work,[],[],False{}} <> C.AsyncWriteSchedule{} <> rest,stack),state(w,work,rest,stack),healthyStep(w,Q.Walk{0n,child,child} <> work,rest,stack,healthy),{==})

def release(+w: R.World,+work: List<&2,Q.Task>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,healthy: {B.ok(w) == True{} : Bool}) -> {C.step(state(w,Q.Release{0n} <> work,rest,stack)) == state(w,work,rest,stack) : C.Machine}:
  Equal.trans(C.Machine,C.step(state(w,Q.Release{0n} <> work,rest,stack)),C.dispatch(w,C.PendingTasks{Q.Release{0n} <> work,[],[],False{}} <> C.AsyncWriteSchedule{} <> rest,stack),state(w,work,rest,stack),healthyStep(w,Q.Release{0n} <> work,rest,stack,healthy),{==})

def ending(+w: R.World,+work: List<&2,Q.Task>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,healthy: {B.ok(w) == True{} : Bool}) -> {C.step(state(w,Q.End{} <> work,rest,stack)) == state(w,work,rest,stack) : C.Machine}:
  Equal.trans(C.Machine,C.step(state(w,Q.End{} <> work,rest,stack)),C.dispatch(w,C.PendingTasks{Q.End{} <> work,[],[],False{}} <> C.AsyncWriteSchedule{} <> rest,stack),state(w,work,rest,stack),healthyStep(w,Q.End{} <> work,rest,stack,healthy),{==})

def restore(+w: R.World,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,healthy: {B.ok(w) == True{} : Bool},+child: Nat,+after: Bool) -> {C.step(state(w,Q.RestoreSettlement{visited,[],scheduled} <> Descend.tailTasks(after,child,edge,root),rest,stack)) == Descend.chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after) : C.Machine}:
  Equal.trans(C.Machine,C.step(state(w,Q.RestoreSettlement{visited,[],scheduled} <> Descend.tailTasks(after,child,edge,root),rest,stack)),C.dispatch(w,C.PendingTasks{Q.RestoreSettlement{visited,[],scheduled} <> Descend.tailTasks(after,child,edge,root),[],[],False{}} <> C.AsyncWriteSchedule{} <> rest,stack),Descend.chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after),healthyStep(w,Q.RestoreSettlement{visited,[],scheduled} <> Descend.tailTasks(after,child,edge,root),rest,stack,healthy),Descend.chosenExact(w,child,edge,root,visited,scheduled,rest,stack,after))

def prefix(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+healthy: {B.ok(w) == True{} : Bool},+after: Bool) -> {Steps.iterate(4n,input(w,child,edge,root,visited,scheduled,rest,stack,after)) == Descend.chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after) : C.Machine}:
  +resume = {Q.RestoreSettlement{visited,[],scheduled} <> Descend.tailTasks(after,child,edge,root) : List<&2,Q.Task>}
  +before = input(w,child,edge,root,visited,scheduled,rest,stack,after)
  +one = state(w,Q.Release{0n} <> Q.End{} <> resume,rest,stack)
  +two = state(w,Q.End{} <> resume,rest,stack)
  +three = state(w,resume,rest,stack)
  +first = zero(w,child,Q.Release{0n} <> Q.End{} <> resume,rest,stack,healthy)
  +second = Driver.appendStep(1n,before,one,two,first,release(w,Q.End{} <> resume,rest,stack,healthy))
  +third = Driver.appendStep(2n,before,two,three,second,ending(w,resume,rest,stack,healthy))
  Driver.appendStep(3n,before,three,Descend.chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after),third,restore(w,edge,root,visited,scheduled,rest,stack,healthy,child,after))

def fault(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+broken: {B.ok(w) == False{} : Bool},+after: Bool) -> {Steps.iterate(2n,input(w,child,edge,root,visited,scheduled,rest,stack,after)) == C.Machine{w,rest,stack} : C.Machine}:
  Driver.appendStep(1n,input(w,child,edge,root,visited,scheduled,rest,stack,after),C.Machine{w,C.AsyncWriteSchedule{} <> rest,stack},C.Machine{w,rest,stack},Suffix.faultPendingFirst(w,tasks(child,edge,root,visited,scheduled,after),[],False{},rest,stack,broken),Suffix.faultLast(w,rest,stack,broken))

def completeBy(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+end: {R.Link.nextSub(B.link(w,edge)) == 0n : Nat},ready: Bool,known: {B.ok(w) == ready : Bool},+after: Bool,+zero: {R.Node.subs(B.node(w,child)) == 0n : Nat}) -> Return.Returned<input(w,child,edge,root,visited,scheduled,rest,stack,after),rest,stack,12n>:
  match ready:
    case True{}:
      Return.prepend(input(w,child,edge,root,visited,scheduled,rest,stack,after),Descend.chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after),rest,stack,4n,8n,prefix(w,child,edge,root,visited,scheduled,rest,stack,known,after),Descend.chosenComplete(w,child,edge,root,visited,scheduled,rest,stack,end,zero,after))
    case False{}:
      Return.ReturnedAt{2n,10n,w,{==},fault(w,child,edge,root,visited,scheduled,rest,stack,known,after)}

def complete(+w: R.World,child: Nat,edge: Nat,root: Nat,visited: List<&2,Nat>,scheduled: Bool,rest: List<&2,C.Task>,stack: List<&2,R.Value>,end: {R.Link.nextSub(B.link(w,edge)) == 0n : Nat},+after: Bool,+zero: {R.Node.subs(B.node(w,child)) == 0n : Nat}) -> Return.Returned<input(w,child,edge,root,visited,scheduled,rest,stack,after),rest,stack,12n>:
  completeBy(w,child,edge,root,visited,scheduled,rest,stack,end,B.ok(w),{==},after,zero)

def frameBy(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+end: {R.Link.nextSub(B.link(w,edge)) == 0n : Nat},ready: Bool,+known: {B.ok(w) == ready : Bool},+after: Bool,+zero: {R.Node.subs(B.node(w,child)) == 0n : Nat}) -> {Frame.observe(Return.world(input(w,child,edge,root,visited,scheduled,rest,stack,after),rest,stack,12n,completeBy(w,child,edge,root,visited,scheduled,rest,stack,end,ready,known,after,zero))) == Frame.observe(w) : Frame.View}:
  match ready:
    case True{}:
      FramedReturn.prepend(input(w,child,edge,root,visited,scheduled,rest,stack,after),Descend.chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after),rest,stack,4n,8n,prefix(w,child,edge,root,visited,scheduled,rest,stack,known,after),Descend.chosenComplete(w,child,edge,root,visited,scheduled,rest,stack,end,zero,after),Equal.cong(R.World,Frame.View,world=>Frame.observe(world),C.world(Descend.chosenInput(w,child,edge,root,visited,scheduled,rest,stack,after)),w,Descend.chosenWorld(w,child,edge,root,visited,scheduled,rest,stack,after)),Descend.chosenFrameAt(w,child,edge,root,visited,scheduled,rest,stack,end,zero,after))
    case False{}: {==}

def frame(+w: R.World,+child: Nat,+edge: Nat,+root: Nat,+visited: List<&2,Nat>,+scheduled: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+end: {R.Link.nextSub(B.link(w,edge)) == 0n : Nat},+after: Bool,+zero: {R.Node.subs(B.node(w,child)) == 0n : Nat}) -> {Frame.observe(Return.world(input(w,child,edge,root,visited,scheduled,rest,stack,after),rest,stack,12n,complete(w,child,edge,root,visited,scheduled,rest,stack,end,after,zero))) == Frame.observe(w) : Frame.View}:
  frameBy(w,child,edge,root,visited,scheduled,rest,stack,end,B.ok(w),{==},after,zero)
