# The first ordinary yielded-value delivery marks its cell before the admitted
# body. Real preparation/setters/retirement/output preserve that cell. Any later
# permitted wait append/mark history still makes a repeated current lookup an
# exact Machine no-op, with no second write or debt retirement.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./action-body-entry.bend as Entry
import ./ordinary-body-entry.bend as Grammar
import ./held-body-return.bend as Body
import ./held-write-history.bend as History
import ./held-write-profile.bend as P
import ./held-write-outer.bend as HeldFrame
import ./held-preparation-source.bend as Source
import ./held-alias-body-input.bend as BodyInput
import ./held-resume-retirement.bend as Resume
import ./action-output-frame.bend as Output
import ./action-body-retirement.bend as Exit
import ./action-body-guard.bend as Guard
import ./action-first-frame.bend as First
import ./action-method-first-history.bend as FirstHistory
import ./observer-write-frame.bend as Observer
import ./action-delivery-input.bend as Input
import ./held-action-delivery.bend as Delivery
import ./transaction-rejoin-history.bend as Alias
import ./action-wait-history.bend as WaitHistory
import ./action-laws.bend as Laws

def preparedWaits(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> {R.World.actionWaits(Entry.prepared(w,actor,R.ActionEnd{})) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  +next = Entry.prepared(w,actor,R.ActionEnd{})
  +start = Resume.start(w,actor,rest,stack,incoming,rejected)
  +body = Body.start(next,values,id,answer,actor,C.ActionSliceEnd{R.World.question(w)} <> rest,stack)
  +fromStart = Equal.cong(C.Machine,List<&2,R.ActionWait>,m=>R.World.actionWaits(C.world(m)),start,body,Resume.first(w,actor,values,id,answer,rest,stack,incoming,rejected,known))
  +fromObserver = Equal.cong(Observer.View,List<&2,R.ActionWait>,view=>Observer.waitEntries(view),Observer.observe(C.world(start)),Observer.observe(w),First.resume(w,rest,stack,actor,incoming,rejected,Grammar.method(values,id,answer,R.ActionEnd{}),known))
  Equal.trans(List<&2,R.ActionWait>,R.World.actionWaits(next),R.World.actionWaits(C.world(start)),R.World.actionWaits(w),Equal.sym(List<&2,R.ActionWait>,R.World.actionWaits(C.world(start)),R.World.actionWaits(next),fromStart),fromObserver)

def through(+w: R.World,+observer: Nat,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+remaining: Nat,profile: P.Profile<Entry.prepared(Input.marked(w,observer),actor,R.ActionEnd{}),id,offset>,+known: {R.ActionState.methods(A.get(Input.marked(w,observer),actor)) == Resume.methods(values,id,answer) : R.Expr},completed: {Output.outer(C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values))) == Output.outer(Exit.target(History.run(values,Entry.prepared(Input.marked(w,observer),actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}) -> {R.World.actionWaits(C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values))) == R.World.actionWaits(Input.marked(w,observer)) : List<&2,R.ActionWait>}:
  +marked = Input.marked(w,observer)
  +next = Entry.prepared(marked,actor,R.ActionEnd{})
  +written = History.run(values,next,id)
  +target = Exit.target(written,1n+offset,remaining)
  +returned = C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values))
  +writes = HeldFrame.sameActionWaits(next,written,R.Node.x(B.node(next,id)),History.outer(values,next,id,offset,profile))
  +preparation = preparedWaits(marked,actor,values,id,answer,rest,stack,incoming,rejected,known)
  Equal.trans(List<&2,R.ActionWait>,R.World.actionWaits(returned),R.World.actionWaits(target),R.World.actionWaits(marked),Guard.sameWaits(returned,target,completed),Equal.trans(List<&2,R.ActionWait>,R.World.actionWaits(target),R.World.actionWaits(written),R.World.actionWaits(marked),Guard.targetWaits(written,1n+offset,remaining),Equal.trans(List<&2,R.ActionWait>,R.World.actionWaits(written),R.World.actionWaits(next),R.World.actionWaits(marked),writes,preparation)))

def tasks(machine: C.Machine) -> List<&2,C.Task>:
  match machine:
    case C.Machine{world,tasks,values}: tasks

def afterEvents(+w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,observer: Nat,incoming: R.Value,rejected: Bool,values: List<&2,R.Value>,events: List<&2,WaitHistory.WaitEvent>) -> C.Machine:
  +done = Delivery.after(w,rest,stack,observer,rejected,incoming,values)
  C.Machine{WaitHistory.run(events,C.world(done)),tasks(done),C.values(done)}

def currentWaits(+w: R.World,+observer: Nat,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<w,id,offset>,+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr},+found: {A.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}) -> {R.World.actionWaits(C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values))) == R.World.actionWaits(Input.marked(w,observer)) : List<&2,R.ActionWait>}:
  +marked = Input.marked(w,observer)
  +profile = BodyInput.current(marked,id,actor,offset,captureOffset,R.ActionEnd{},Input.profile(w,observer,id,offset,initial),Input.markedAlias(w,observer,offset,alias),Input.capture(w,observer,actor,offset,alias,captured),Input.positive(w,observer,offset,captureOffset,alias,positive))
  through(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,remaining,profile,Input.methods(w,observer,actor,Resume.methods(values,id,answer),known),Delivery.current(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,open,known,found))

def currentFound(+w: R.World,+observer: Nat,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<w,id,offset>,+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr},+found: {A.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}) -> {A.find(R.World.actionWaits(C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values))),observer) == Some{R.ActionWait{observer,actor,0,True{}}} : Maybe<&2,R.ActionWait>}:
  +done = C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values))
  +marked = Input.marked(w,observer)
  Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(done),observer),A.find(R.World.actionWaits(marked),observer),Some{R.ActionWait{observer,actor,0,True{}}},Equal.cong(List<&2,R.ActionWait>,Maybe<&2,R.ActionWait>,rows=>A.find(rows,observer),R.World.actionWaits(done),R.World.actionWaits(marked),currentWaits(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,open,known,found)),FirstHistory.markedFound(w,observer,actor,found))

def currentDuplicate(+w: R.World,+observer: Nat,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<w,id,offset>,+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr},+found: {A.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>},+events: List<&2,WaitHistory.WaitEvent>,+lateRejected: Bool,+lateValue: R.Value) -> {C.asyncActionDelivery(C.world(afterEvents(w,rest,stack,observer,incoming,rejected,values,events)),tasks(afterEvents(w,rest,stack,observer,incoming,rejected,values,events)),C.values(afterEvents(w,rest,stack,observer,incoming,rejected,values,events)),observer,lateRejected,lateValue,A.find(R.World.actionWaits(C.world(afterEvents(w,rest,stack,observer,incoming,rejected,values,events))),observer)) == afterEvents(w,rest,stack,observer,incoming,rejected,values,events) : C.Machine}:
  +done = C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values))
  +machine = afterEvents(w,rest,stack,observer,incoming,rejected,values,events)
  +next = C.world(machine)
  +work = tasks(machine)
  +saved = C.values(machine)
  +foundAfter = WaitHistory.historyFound(events,done,observer,observer,actor,0,currentFound(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,open,known,found))
  Equal.trans(C.Machine,C.asyncActionDelivery(next,work,saved,observer,lateRejected,lateValue,A.find(R.World.actionWaits(next),observer)),C.asyncActionDelivery(next,work,saved,observer,lateRejected,lateValue,Some{R.ActionWait{observer,actor,0,True{}}}),machine,Equal.cong(Maybe<&2,R.ActionWait>,C.Machine,entry=>C.asyncActionDelivery(next,work,saved,observer,lateRejected,lateValue,entry),A.find(R.World.actionWaits(next),observer),Some{R.ActionWait{observer,actor,0,True{}}},foundAfter),Laws.duplicate_yield(next,work,saved,observer,actor,lateRejected,lateValue))

def freshWaits(+w: R.World,+observer: Nat,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Source.flush(w,1n+offset),id,offset>,+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr},+found: {A.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}) -> {R.World.actionWaits(C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values))) == R.World.actionWaits(Input.marked(w,observer)) : List<&2,R.ActionWait>}:
  +marked = Input.marked(w,observer)
  +profile = BodyInput.fresh(marked,id,actor,offset,captureOffset,R.ActionEnd{},Input.freshProfile(w,observer,id,offset,initial),Input.markedAlias(w,observer,offset,alias),Input.capture(w,observer,actor,offset,alias,captured),Input.positive(w,observer,offset,captureOffset,alias,positive),Equal.trans(Nat,R.World.flushTransaction(marked),R.World.flushTransaction(w),0n,Input.future(w,observer),empty))
  through(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,remaining,profile,Input.methods(w,observer,actor,Resume.methods(values,id,answer),known),Delivery.fresh(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known,found))

def freshFound(+w: R.World,+observer: Nat,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Source.flush(w,1n+offset),id,offset>,+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr},+found: {A.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}) -> {A.find(R.World.actionWaits(C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values))),observer) == Some{R.ActionWait{observer,actor,0,True{}}} : Maybe<&2,R.ActionWait>}:
  +done = C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values))
  +marked = Input.marked(w,observer)
  Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(done),observer),A.find(R.World.actionWaits(marked),observer),Some{R.ActionWait{observer,actor,0,True{}}},Equal.cong(List<&2,R.ActionWait>,Maybe<&2,R.ActionWait>,rows=>A.find(rows,observer),R.World.actionWaits(done),R.World.actionWaits(marked),freshWaits(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known,found)),FirstHistory.markedFound(w,observer,actor,found))

def freshDuplicate(+w: R.World,+observer: Nat,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Source.flush(w,1n+offset),id,offset>,+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr},+found: {A.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>},+events: List<&2,WaitHistory.WaitEvent>,+lateRejected: Bool,+lateValue: R.Value) -> {C.asyncActionDelivery(C.world(afterEvents(w,rest,stack,observer,incoming,rejected,values,events)),tasks(afterEvents(w,rest,stack,observer,incoming,rejected,values,events)),C.values(afterEvents(w,rest,stack,observer,incoming,rejected,values,events)),observer,lateRejected,lateValue,A.find(R.World.actionWaits(C.world(afterEvents(w,rest,stack,observer,incoming,rejected,values,events))),observer)) == afterEvents(w,rest,stack,observer,incoming,rejected,values,events) : C.Machine}:
  +done = C.world(Delivery.after(w,rest,stack,observer,rejected,incoming,values))
  +machine = afterEvents(w,rest,stack,observer,incoming,rejected,values,events)
  +next = C.world(machine)
  +work = tasks(machine)
  +saved = C.values(machine)
  +foundAfter = WaitHistory.historyFound(events,done,observer,observer,actor,0,freshFound(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known,found))
  Equal.trans(C.Machine,C.asyncActionDelivery(next,work,saved,observer,lateRejected,lateValue,A.find(R.World.actionWaits(next),observer)),C.asyncActionDelivery(next,work,saved,observer,lateRejected,lateValue,Some{R.ActionWait{observer,actor,0,True{}}}),machine,Equal.cong(Maybe<&2,R.ActionWait>,C.Machine,entry=>C.asyncActionDelivery(next,work,saved,observer,lateRejected,lateValue,entry),A.find(R.World.actionWaits(next),observer),Some{R.ActionWait{observer,actor,0,True{}}},foundAfter),Laws.duplicate_yield(next,work,saved,observer,actor,lateRejected,lateValue))
