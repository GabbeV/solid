# Construction supplies body health, the captured terminal route and its debt
# after arbitrary admitted callback-table helper prefixes. No final-count premise.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./action-method-wait-fixture.bend as Input
import ./action-method-first-history.bend as First
import ./action-first-frame.bend as Frame
import ./action-helper-context.bend as Context
import ./action-context-reconstruction.bend as Reconstruct
import ./action-wait-history.bend as History
import ./action-body-entry.bend as Entry
import ./action-body-return.bend as Body
import ./action-body-retirement.bend as Retire
import ./action-output-frame.bend as Output
import ./transaction-resolution.bend as Paths
import ./pending-stack-history.bend as Steps

def initial(values: List<&2,R.Value>,value: R.Value,tail: R.Expr) -> R.World:
  Input.initial(values,Entry.method(value,tail))

def marked(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> R.World:
  +method = Entry.method(value,tail)
  Frame.marked(Input.registered(values,method,prefix),Input.fresh(values,method,prefix))

def context(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {Context.erase(marked(values,value,tail,prefix)) == Context.erase(initial(values,value,tail)) : R.World}:
  +method = Entry.method(value,tail)
  +before = Input.before(values,method,prefix)
  +registered = Input.registered(values,method,prefix)
  +observer = Input.fresh(values,method,prefix)
  Context.compose(initial(values,value,tail),registered,marked(values,value,tail,prefix),Context.waits(registered,A.settleWait(R.World.actionWaits(registered),observer)),Context.compose(initial(values,value,tail),before,registered,Context.registered(before,Input.action(values,method),Input.result(values,method),0),Context.history(prefix,initial(values,value,tail))))

def ready(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,prefix: List<&2,History.WaitEvent>) -> R.World:
  Entry.prepared(marked(values,value,tail,prefix),Input.action(values,Entry.method(value,tail)),tail)

def model(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> R.World:
  Entry.prepared(Reconstruct.restore(Context.erase(initial(values,value,tail)),marked(values,value,tail,prefix)),Input.action(values,Entry.method(value,tail)),tail)

def shape(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {ready(values,value,tail,prefix) == model(values,value,tail,prefix) : R.World}:
  Equal.cong(R.World,R.World,w=>Entry.prepared(w,Input.action(values,Entry.method(value,tail)),tail),marked(values,value,tail,prefix),Reconstruct.restore(Context.erase(initial(values,value,tail)),marked(values,value,tail,prefix)),Reconstruct.shape(marked(values,value,tail,prefix),initial(values,value,tail),context(values,value,tail,prefix)))

def modelHealth(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.World.fault(model(values,value,tail,prefix)) == R.Healthy{} : R.Fault}:
  {==}

def healthy(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.World.fault(ready(values,value,tail,prefix)) == R.Healthy{} : R.Fault}:
  Equal.trans(R.Fault,R.World.fault(ready(values,value,tail,prefix)),R.World.fault(model(values,value,tail,prefix)),R.Healthy{},Equal.cong(R.World,R.Fault,w=>R.World.fault(w),ready(values,value,tail,prefix),model(values,value,tail,prefix),shape(values,value,tail,prefix)),modelHealth(values,value,tail,prefix))

def modelInto(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.Transaction.into(B.transaction(model(values,value,tail,prefix),1n)) == 0n : Nat}:
  {==}

def stopped(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.Transaction.into(B.transaction(ready(values,value,tail,prefix),1n)) == 0n : Nat}:
  Equal.trans(Nat,R.Transaction.into(B.transaction(ready(values,value,tail,prefix),1n)),R.Transaction.into(B.transaction(model(values,value,tail,prefix),1n)),0n,Equal.cong(R.World,Nat,w=>R.Transaction.into(B.transaction(w,1n)),ready(values,value,tail,prefix),model(values,value,tail,prefix),shape(values,value,tail,prefix)),modelInto(values,value,tail,prefix))

def modelCapture(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.ActionState.transaction(A.get(model(values,value,tail,prefix),Input.action(values,Entry.method(value,tail)))) == 1n : Nat}:
  {==}

def captured(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.ActionState.transaction(A.get(ready(values,value,tail,prefix),Input.action(values,Entry.method(value,tail)))) == 1n : Nat}:
  Equal.trans(Nat,R.ActionState.transaction(A.get(ready(values,value,tail,prefix),Input.action(values,Entry.method(value,tail)))),R.ActionState.transaction(A.get(model(values,value,tail,prefix),Input.action(values,Entry.method(value,tail)))),1n,Equal.cong(R.World,Nat,w=>R.ActionState.transaction(A.get(w,Input.action(values,Entry.method(value,tail)))),ready(values,value,tail,prefix),model(values,value,tail,prefix),shape(values,value,tail,prefix)),modelCapture(values,value,tail,prefix))

def modelDebt(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.Transaction.open(B.transaction(model(values,value,tail,prefix),1n)) == 1n : Nat}:
  {==}

def debt(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.Transaction.open(B.transaction(ready(values,value,tail,prefix),1n)) == 1n : Nat}:
  Equal.trans(Nat,R.Transaction.open(B.transaction(ready(values,value,tail,prefix),1n)),R.Transaction.open(B.transaction(model(values,value,tail,prefix),1n)),1n,Equal.cong(R.World,Nat,w=>R.Transaction.open(B.transaction(w,1n)),ready(values,value,tail,prefix),model(values,value,tail,prefix),shape(values,value,tail,prefix)),modelDebt(values,value,tail,prefix))


def firstExact(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {First.first(values,Entry.method(value,tail),prefix,rest,stack,rejected,incoming) == Body.start(ready(values,value,tail,prefix),C.ActionSliceEnd{R.World.question(marked(values,value,tail,prefix))} <> rest,stack,Input.action(values,Entry.method(value,tail)),value) : C.Machine}:
  +method = Entry.method(value,tail)
  +w = Input.registered(values,method,prefix)
  +observer = Input.fresh(values,method,prefix)
  +id = Input.action(values,method)
  +entry = {R.ActionWait{observer,id,0,False{}} : R.ActionWait}
  Equal.trans(C.Machine,First.first(values,method,prefix,rest,stack,rejected,incoming),C.actionDelivery(w,rest,stack,entry,rejected,incoming),Body.start(ready(values,value,tail,prefix),C.ActionSliceEnd{R.World.question(marked(values,value,tail,prefix))} <> rest,stack,id,value),Equal.cong(Maybe<&2,R.ActionWait>,C.Machine,found=>C.asyncActionDelivery(w,rest,stack,observer,rejected,incoming,found),A.find(R.World.actionWaits(w),observer),Some{entry},Input.lookup(values,method,prefix)),Entry.resume(marked(values,value,tail,prefix),rest,stack,id,incoming,rejected,value,tail,Frame.methodTransport(w,marked(values,value,tail,prefix),id,method,Frame.markedActions(w,observer),First.methods(values,method,prefix))))

def returned(+values: List<&2,R.Value>,value: R.Value,tail: R.Expr,prefix: List<&2,History.WaitEvent>,rest: List<&2,C.Task>,stack: List<&2,R.Value>,incoming: R.Value,rejected: Bool) -> C.Machine:
  Steps.iterate(2n,First.first(values,Entry.method(value,tail),prefix,rest,stack,rejected,incoming))

def completedOuter(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Output.outer(C.world(returned(values,value,tail,prefix,rest,stack,incoming,rejected))) == Output.outer(Retire.target(ready(values,value,tail,prefix),1n,0n)) : R.World}:
  +w = ready(values,value,tail,prefix)
  +id = Input.action(values,Entry.method(value,tail))
  +path = {Paths.Root{1n,stopped(values,value,tail,prefix)} : Paths.Route<w>}
  +work = {C.ActionSliceEnd{R.World.question(marked(values,value,tail,prefix))} <> rest : List<&2,C.Task>}
  Equal.trans(R.World,Output.outer(C.world(returned(values,value,tail,prefix,rest,stack,incoming,rejected))),Output.outer(C.world(Steps.iterate(2n,Body.start(w,work,stack,id,value)))),Output.outer(Retire.target(w,1n,0n)),Equal.cong(C.Machine,R.World,m=>Output.outer(C.world(Steps.iterate(2n,m))),First.first(values,Entry.method(value,tail),prefix,rest,stack,rejected,incoming),Body.start(w,work,stack,id,value),firstExact(values,value,tail,prefix,rest,stack,incoming,rejected)),Retire.complete(w,work,stack,id,value,path,B.length(R.Transaction,R.World.txArena(w)),0n,healthy(values,value,tail,prefix),captured(values,value,tail,prefix),{==},debt(values,value,tail,prefix)))
