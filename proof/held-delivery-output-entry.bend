# Exact ordinary yielded-callback body-to-output machine and caller work shape.
# Source/capture/route/method/lookup assumptions concern entry, not a result.
import Base
import ../representation/base.bend as B
import ./action-retirement-health.bend as Health
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./held-write-profile.bend as P
import ./held-preparation-source.bend as Source
import ./held-alias-body-input.bend as Prepare
import ./transaction-rejoin-history.bend as Alias
import ./action-delivery-input.bend as Mark
import ./held-action-delivery.bend as Delivery
import ./held-resume-retirement.bend as Resume
import ./action-body-entry.bend as Entry
import ./held-body-evaluation.bend as Eval
import ./held-body-return.bend as Body
import ./held-write-history.bend as History
import ./pending-stack-history.bend as Steps
import ./action-output-continuation.bend as Queue

def work(+w: R.World,observer: Nat,rest: List<&2,C.Task>) -> List<&2,C.Task>:
  C.ActionSliceEnd{R.World.question(Mark.marked(w,observer))} <> rest

def preparedProfile(+w: R.World,+observer: Nat,+actor: Nat,+id: Nat,+offset: Nat,+captureOffset: Nat,+initial: P.Profile<Source.flush(w,1n+offset),id,offset>,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat}) -> P.Profile<Entry.prepared(Mark.marked(w,observer),actor,R.ActionEnd{}),id,offset>:
  +marked = Mark.marked(w,observer)
  Prepare.fresh(marked,id,actor,offset,captureOffset,R.ActionEnd{},Mark.freshProfile(w,observer,id,offset,initial),Mark.markedAlias(w,observer,offset,alias),Mark.capture(w,observer,actor,offset,alias,captured),Mark.positive(w,observer,offset,captureOffset,alias,positive),Equal.trans(Nat,R.World.flushTransaction(marked),R.World.flushTransaction(w),0n,Mark.future(w,observer),empty))

def exact(+w: R.World,+observer: Nat,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+initial: P.Profile<Source.flush(w,1n+offset),id,offset>,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat},known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr},found: {A.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}) -> {Delivery.after(w,rest,stack,observer,rejected,incoming,values) == Body.done(Entry.prepared(Mark.marked(w,observer),actor,R.ActionEnd{}),values,id,answer,actor,work(w,observer,rest),stack) : C.Machine}:
  +marked = Mark.marked(w,observer)
  +next = Entry.prepared(marked,actor,R.ActionEnd{})
  +start = Body.start(next,values,id,answer,actor,work(w,observer,rest),stack)
  +first = Equal.trans(C.Machine,Delivery.start(w,rest,stack,observer,rejected,incoming),Resume.start(marked,actor,rest,stack,incoming,rejected),start,Delivery.accepted(w,rest,stack,observer,actor,rejected,incoming,found),Resume.first(marked,actor,values,id,answer,rest,stack,incoming,rejected,Mark.methods(w,observer,actor,Resume.methods(values,id,answer),known)))
  Equal.trans(C.Machine,Delivery.after(w,rest,stack,observer,rejected,incoming,values),Steps.iterate(1n+Eval.cost(values),start),Body.done(next,values,id,answer,actor,work(w,observer,rest),stack),Equal.cong(C.Machine,C.Machine,m=>Steps.iterate(1n+Eval.cost(values),m),Delivery.start(w,rest,stack,observer,rejected,incoming),start,first),Body.complete(values,next,id,answer,actor,work(w,observer,rest),stack,offset,preparedProfile(w,observer,actor,id,offset,captureOffset,initial,alias,captured,positive,empty)))

def queue(+w: R.World,+observer: Nat,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+initial: P.Profile<Source.flush(w,1n+offset),id,offset>,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat},known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr},found: {A.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}) -> Queue.Queue<Delivery.after(w,rest,stack,observer,rejected,incoming,values),work(w,observer,rest),stack>:
  +next = Entry.prepared(Mark.marked(w,observer),actor,R.ActionEnd{})
  +done = Body.done(next,values,id,answer,actor,work(w,observer,rest),stack)
  Queue.substitute(done,Delivery.after(w,rest,stack,observer,rejected,incoming,values),work(w,observer,rest),stack,Equal.sym(C.Machine,Delivery.after(w,rest,stack,observer,rejected,incoming,values),done,exact(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,empty,known,found)),Queue.done(A.exit(History.run(values,next,id)),work(w,observer,rest),stack,actor,False{},answer))

def healthy(+w: R.World,+observer: Nat,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Source.flush(w,1n+offset),id,offset>,+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr},+found: {A.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}) -> {R.World.fault(C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values))) == R.Healthy{} : R.Fault}:
  +next = Entry.prepared(Mark.marked(w,observer),actor,R.ActionEnd{})
  +written = History.run(values,next,id)
  +profile = preparedProfile(w,observer,actor,id,offset,captureOffset,initial,alias,captured,positive,empty)
  Health.healthy(written,C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values)),1n+offset,remaining,P.healthy(written,id,offset,History.invariant(values,next,id,offset,profile)),Delivery.fresh(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known,found))

def drain(+w: R.World,+observer: Nat,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Source.flush(w,1n+offset),id,offset>,+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr},+found: {A.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}) -> {Steps.iterate(Queue.cost(Delivery.after(w,rest,stack,observer,rejected,incoming,values),work(w,observer,rest),stack,queue(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,empty,known,found)),Delivery.after(w,rest,stack,observer,rejected,incoming,values)) == C.Machine{Queue.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values),work(w,observer,rest),stack,queue(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,empty,known,found)),work(w,observer,rest),stack} : C.Machine}:
  +machine = Delivery.after(w,rest,stack,observer,rejected,incoming,values)
  +form = queue(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,empty,known,found)
  Queue.drain(machine,work(w,observer,rest),stack,form,healthy(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known,found))
