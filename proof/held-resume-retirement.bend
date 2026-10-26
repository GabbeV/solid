# Local actual callback entry through a whole admitted held setter body and
# retirement. Only initial source/capture/debt facts are supplied; preparation
# derives the body profile, capture and transaction storage. No host/public
# reachability, once-only delivery or eventual publication is inferred here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./ordinary-body-entry.bend as Entry
import ./action-body-entry.bend as Prepared
import ./action-first-frame.bend as First
import ./held-write-profile.bend as P
import ./held-preparation-profile.bend as Input
import ./held-preparation-source.bend as Prepare
import ./held-preparation-control.bend as Control
import ./held-body-evaluation.bend as Eval
import ./held-body-return.bend as Body
import ./held-body-retirement.bend as Retire
import ./held-write-history.bend as History
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./transaction-resolution.bend as Routes
import ./pending-stack-history.bend as Steps

def methods(+values: List<&2,R.Value>,+id: Nat,+answer: R.Value) -> R.Expr:
  First.expression(Entry.method(values,id,answer,R.ActionEnd{}))

def start(+w: R.World,+actor: Nat,rest: List<&2,C.Task>,stack: List<&2,R.Value>,incoming: R.Value,rejected: Bool) -> C.Machine:
  C.actionResume(w,rest,stack,actor,incoming,rejected)

def first(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,known: {R.ActionState.methods(A.get(w,actor)) == methods(values,id,answer) : R.Expr}) -> {start(w,actor,rest,stack,incoming,rejected) == Body.start(Prepared.prepared(w,actor,R.ActionEnd{}),values,id,answer,actor,C.ActionSliceEnd{R.World.question(w)} <> rest,stack) : C.Machine}:
  Entry.resume(w,rest,stack,actor,incoming,rejected,values,id,answer,R.ActionEnd{},known)

def through(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+remaining: Nat,+profile: P.Profile<Prepared.prepared(w,actor,R.ActionEnd{}),id,offset>,capture: {R.ActionState.transaction(A.get(Prepared.prepared(w,actor,R.ActionEnd{}),actor)) == 1n+offset : Nat},+arena: {R.World.txArena(Prepared.prepared(w,actor,R.ActionEnd{})) == R.World.txArena(w) : List<&2,R.Transaction>},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},known: {R.ActionState.methods(A.get(w,actor)) == methods(values,id,answer) : R.Expr}) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),start(w,actor,rest,stack,incoming,rejected)))) == Output.outer(Exit.target(History.run(values,Prepared.prepared(w,actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}:
  +next = Prepared.prepared(w,actor,R.ActionEnd{})
  +root = {1n+offset : Nat}
  +route = {Routes.Root{root,P.terminal(next,id,offset,profile)} : Routes.Route<next>}
  +extra = B.length(R.Transaction,R.World.txArena(next))
  +nextOpen = Equal.trans(Nat,R.Transaction.open(B.transaction(next,root)),R.Transaction.open(B.transaction(w,root)),1n+remaining,Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.open(B.get(R.Transaction,rows,root,B.blank_transaction())),R.World.txArena(next),R.World.txArena(w),arena),open)
  +work = {C.ActionSliceEnd{R.World.question(w)} <> rest : List<&2,C.Task>}
  Equal.trans(R.World,Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),start(w,actor,rest,stack,incoming,rejected)))),Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(next,values,id,answer,actor,work,stack)))),Output.outer(Exit.target(History.run(values,next,id),root,remaining)),Equal.cong(C.Machine,R.World,m=>Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),m))),start(w,actor,rest,stack,incoming,rejected),Body.start(next,values,id,answer,actor,work,stack),first(w,actor,values,id,answer,rest,stack,incoming,rejected,known)),Retire.complete(values,next,id,answer,actor,work,stack,offset,profile,route,extra,remaining,capture,{==},nextOpen))

def current(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+remaining: Nat,+initial: P.Profile<w,id,offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == 1n+offset : Nat},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},known: {R.ActionState.methods(A.get(w,actor)) == methods(values,id,answer) : R.Expr}) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),start(w,actor,rest,stack,incoming,rejected)))) == Output.outer(Exit.target(History.run(values,Prepared.prepared(w,actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}:
  through(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,remaining,Input.current(w,id,actor,offset,R.ActionEnd{},initial,captured),Control.capture(w,actor,offset,R.ActionEnd{},captured),Control.arena(w,actor,offset,R.ActionEnd{},captured,P.future(w,id,offset,initial),P.terminal(w,id,offset,initial)),open,known)

def fresh(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+remaining: Nat,+initial: P.Profile<Prepare.flush(w,1n+offset),id,offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == 1n+offset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},known: {R.ActionState.methods(A.get(w,actor)) == methods(values,id,answer) : R.Expr}) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),start(w,actor,rest,stack,incoming,rejected)))) == Output.outer(Exit.target(History.run(values,Prepared.prepared(w,actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}:
  +root = {1n+offset : Nat}
  +terminal = Equal.trans(Nat,R.Transaction.into(B.transaction(w,root)),R.Transaction.into(B.transaction(Prepare.flush(w,root),root)),0n,Equal.sym(Nat,R.Transaction.into(B.transaction(Prepare.flush(w,root),root)),R.Transaction.into(B.transaction(w,root)),Input.originalTerminal(w,root)),P.terminal(Prepare.flush(w,root),id,offset,initial))
  through(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,remaining,Input.actual(w,id,actor,offset,R.ActionEnd{},initial,captured,empty),Control.capture(w,actor,offset,R.ActionEnd{},captured),Control.freshArena(w,actor,offset,R.ActionEnd{},captured,empty,terminal),open,known)
