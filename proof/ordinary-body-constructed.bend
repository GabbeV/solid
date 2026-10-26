# Actual signal/render/link/action construction supplies the body profile and
# original captured-group debt. This is a constructed controller entry, not a
# proof of every public generator invocation or external callback delivery.
import Base
import ./ordinary-body-construction-normal.bend as Normal
import ./ordinary-profile-transport.bend as Transport
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ../runtime/constants.bend as K
import ../runtime/equality.bend as Equality
import ./ordinary-write-constructed.bend as Graph
import ./ordinary-write-profile.bend as P
import ./ordinary-write-history.bend as History
import ./ordinary-body-evaluation.bend as Eval
import ./ordinary-body-return.bend as Body
import ./ordinary-body-entry.bend as Entry
import ./ordinary-body-retirement.bend as Retire
import ./action-body-entry.bend as Prepared
import ./action-body-retirement.bend as Exit
import ./action-first-frame.bend as First
import ./action-output-frame.bend as Output
import ./subscriber-walk-step.bend as Path
import ./transaction-resolution.bend as Routes
import ./pending-stack-history.bend as Steps

def actor(initial: R.Value,values: List<&2,R.Value>,answer: R.Value) -> Nat:
  Normal.actor(initial,values,answer)

def opened(initial: R.Value,values: List<&2,R.Value>,answer: R.Value) -> R.World:
  Normal.opened(initial,values,answer)

def ready(initial: R.Value,values: List<&2,R.Value>,answer: R.Value) -> R.World:
  Normal.ready(initial,values,answer)

def normalizedProfile(+initial: R.Value) -> P.Profile<Normal.normalized(Graph.linked(initial)),Graph.source(initial)>:
  +w = Graph.linked(initial)
  Transport.transfer(w,Normal.normalized(w),Graph.source(initial),History.constructed(initial),Normal.nodes(w),Normal.links(w),Normal.comparators(w),Normal.fault(w),Normal.marked(w),Normal.context(w))

def profile(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> P.Profile<ready(initial,values,answer),Graph.source(initial)>:
  Transport.move(Normal.normalized(Graph.linked(initial)),ready(initial,values,answer),Graph.source(initial),Equal.sym(R.World,ready(initial,values,answer),Normal.normalized(Graph.linked(initial)),Normal.normalizedExact(initial,values,answer)),normalizedProfile(initial))

def start(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,incoming: R.Value,rejected: Bool) -> C.Machine:
  C.actionResume(opened(initial,values,answer),rest,stack,actor(initial,values,answer),incoming,rejected)

def first(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {start(initial,values,answer,rest,stack,incoming,rejected) == Body.start(ready(initial,values,answer),values,Graph.source(initial),answer,actor(initial,values,answer),C.ActionSliceEnd{R.World.question(opened(initial,values,answer))} <> rest,stack) : C.Machine}:
  Entry.resume(opened(initial,values,answer),rest,stack,actor(initial,values,answer),incoming,rejected,values,Graph.source(initial),answer,R.ActionEnd{},{==})

def stopped(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> {R.Transaction.into(B.transaction(ready(initial,values,answer),1n)) == 0n : Nat}:
  Equal.trans(Nat,R.Transaction.into(B.transaction(ready(initial,values,answer),1n)),R.Transaction.into(B.transaction(Normal.normalized(Graph.linked(initial)),1n)),0n,Equal.cong(R.World,Nat,state=>R.Transaction.into(B.transaction(state,1n)),ready(initial,values,answer),Normal.normalized(Graph.linked(initial)),Normal.normalizedExact(initial,values,answer)),Normal.stopped(initial))

def groupRoom(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> {1n+B.length(R.Transaction,R.World.txArena(ready(initial,values,answer))) == 3n : Nat}:
  Equal.trans(Nat,1n+B.length(R.Transaction,R.World.txArena(ready(initial,values,answer))),1n+B.length(R.Transaction,R.World.txArena(Normal.normalized(Graph.linked(initial)))),3n,Equal.cong(R.World,Nat,state=>1n+B.length(R.Transaction,R.World.txArena(state)),ready(initial,values,answer),Normal.normalized(Graph.linked(initial)),Normal.normalizedExact(initial,values,answer)),Normal.groupRoom(initial))

def openCount(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> {R.Transaction.open(B.transaction(ready(initial,values,answer),1n)) == 1n : Nat}:
  Equal.trans(Nat,R.Transaction.open(B.transaction(ready(initial,values,answer),1n)),R.Transaction.open(B.transaction(Normal.normalized(Graph.linked(initial)),1n)),1n,Equal.cong(R.World,Nat,state=>R.Transaction.open(B.transaction(state,1n)),ready(initial,values,answer),Normal.normalized(Graph.linked(initial)),Normal.normalizedExact(initial,values,answer)),Normal.openCount(initial))

# Keep transport abstract so checking does not repeatedly unfold the complete
# signal/graph/action construction at every occurrence of the captured actor.
def captureTransfer(+w: R.World,+next: R.World,+id: Nat,same: {w == next : R.World},zero: {id == 0n : Nat},known: {R.ActionState.transaction(A.get(next,0n)) == 1n : Nat}) -> {R.ActionState.transaction(A.get(w,id)) == 1n : Nat}:
  Equal.trans(Nat,R.ActionState.transaction(A.get(w,id)),R.ActionState.transaction(A.get(w,0n)),1n,Equal.cong(Nat,Nat,index=>R.ActionState.transaction(A.get(w,index)),id,0n,zero),Equal.trans(Nat,R.ActionState.transaction(A.get(w,0n)),R.ActionState.transaction(A.get(next,0n)),1n,Equal.cong(R.World,Nat,state=>R.ActionState.transaction(A.get(state,0n)),w,next,same),known))

def captured(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> {R.ActionState.transaction(A.get(ready(initial,values,answer),actor(initial,values,answer))) == 1n : Nat}:
  captureTransfer(ready(initial,values,answer),Normal.normalized(Graph.linked(initial)),actor(initial,values,answer),Normal.normalizedExact(initial,values,answer),Normal.actorZero(initial,values,answer),Normal.capturedZero(Graph.linked(initial)))

def groupValid(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> {Nat.is_lt(1n,B.length(R.Transaction,R.World.txArena(ready(initial,values,answer)))) == True{} : Bool}:
  Equal.trans(Bool,Nat.is_lt(1n,B.length(R.Transaction,R.World.txArena(ready(initial,values,answer)))),Nat.is_lt(1n,B.length(R.Transaction,R.World.txArena(Normal.normalized(Graph.linked(initial))))),True{},Equal.cong(R.World,Bool,state=>Nat.is_lt(1n,B.length(R.Transaction,R.World.txArena(state))),ready(initial,values,answer),Normal.normalized(Graph.linked(initial)),Normal.normalizedExact(initial,values,answer)),Normal.groupValid(initial))

def complete(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),start(initial,values,answer,rest,stack,incoming,rejected)))) == Output.outer(Exit.target(History.run(values,ready(initial,values,answer),Graph.source(initial)),1n,0n)) : R.World}:
  +w = ready(initial,values,answer)
  +id = Graph.source(initial)
  +action = actor(initial,values,answer)
  +route = {Routes.Root{1n,stopped(initial,values,answer)} : Routes.Route<w>}
  +work = {C.ActionSliceEnd{R.World.question(opened(initial,values,answer))} <> rest : List<&2,C.Task>}
  Equal.trans(R.World,Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),start(initial,values,answer,rest,stack,incoming,rejected)))),Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(w,values,id,answer,action,work,stack)))),Output.outer(Exit.target(History.run(values,w,id),1n,0n)),Equal.cong(C.Machine,R.World,m=>Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),m))),start(initial,values,answer,rest,stack,incoming,rejected),Body.start(w,values,id,answer,action,work,stack),first(initial,values,answer,rest,stack,incoming,rejected)),Retire.complete(values,w,id,answer,action,work,stack,profile(initial,values,answer),route,2n,0n,captured(initial,values,answer),groupRoom(initial,values,answer),openCount(initial,values,answer)))
