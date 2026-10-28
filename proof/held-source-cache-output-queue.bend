# Actual representative count after cached-alias resume. Allocation is derived
# from the source profile and transported through the real finite writes; the
# List.set fallback is never treated as a successful retirement store.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./action-body-entry.bend as Entry
import ./held-write-profile.bend as P
import ./held-preparation-source.bend as Source
import ./held-alias-preparation.bend as Prepare
import ./held-alias-body-input.bend as Input
import ./held-source-cache-preparation.bend as CachePrep
import ./held-source-cache-rebase.bend as Cache
import ./held-source-view.bend as V
import ./held-source-transfer.bend as Transfer
import ./held-resume-retirement.bend as Resume
import ./held-body-evaluation.bend as Eval
import ./held-body-return.bend as Body
import ./held-source-cache-retirement.bend as Retire
import ./held-write-history.bend as History
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./transaction-resolution.bend as Path
import ./transaction-rejoin-history.bend as Alias
import ./transaction-route-rebase.bend as Move
import ./pending-stack-history.bend as Steps

import ./held-source-cache-resume.bend as SourceResume
import ./action-retirement-count.bend as Count
import ./held-count-certificate.bend as Debt
import ./held-cache-virtual-history.bend as Virtual
import ./held-cache-body-input.bend as BodyInput

import ./held-source-cache-debt.bend as DebtBody
import ./action-output-continuation.bend as Queue

def work(+w: R.World,rest: List<&2,C.Task>) -> List<&2,C.Task>:
  C.ActionSliceEnd{R.World.question(w)} <> rest

def after(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> C.Machine:
  Steps.iterate(1n+Eval.cost(values),Resume.start(w,actor,rest,stack,incoming,rejected))

def bodyExact(+body: R.World,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+actor: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,input: BodyInput.Input<body,id,offset>) -> {Steps.iterate(1n+Eval.cost(values),Body.start(body,values,id,answer,actor,rest,stack)) == Body.done(body,values,id,answer,actor,rest,stack) : C.Machine}:
  match input:
    case BodyInput.Prepared{source,cached,profile}: Retire.complete(values,body,id,answer,actor,rest,stack,offset,source,cached,profile)

def currentExact(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> {after(w,actor,values,rest,stack,incoming,rejected) == Body.done(Entry.prepared(w,actor,R.ActionEnd{}),values,id,answer,actor,work(w,rest),stack) : C.Machine}:
  +prepared = Entry.prepared(w,actor,R.ActionEnd{})
  +start = Body.start(prepared,values,id,answer,actor,work(w,rest),stack)
  +evaluated = bodyExact(prepared,values,id,answer,actor,work(w,rest),stack,offset,DebtBody.currentPrepared(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known))
  Equal.trans(C.Machine,after(w,actor,values,rest,stack,incoming,rejected),Steps.iterate(1n+Eval.cost(values),start),Body.done(Entry.prepared(w,actor,R.ActionEnd{}),values,id,answer,actor,work(w,rest),stack),Equal.cong(C.Machine,C.Machine,m=>Steps.iterate(1n+Eval.cost(values),m),Resume.start(w,actor,rest,stack,incoming,rejected),start,Resume.first(w,actor,values,id,answer,rest,stack,incoming,rejected,known)),evaluated)

def currentQueue(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> Queue.Queue<after(w,actor,values,rest,stack,incoming,rejected),work(w,rest),stack>:
  Queue.substitute(Body.done(Entry.prepared(w,actor,R.ActionEnd{}),values,id,answer,actor,work(w,rest),stack),after(w,actor,values,rest,stack,incoming,rejected),work(w,rest),stack,Equal.sym(C.Machine,after(w,actor,values,rest,stack,incoming,rejected),Body.done(Entry.prepared(w,actor,R.ActionEnd{}),values,id,answer,actor,work(w,rest),stack),currentExact(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known)),Queue.done(A.exit(History.run(values,Entry.prepared(w,actor,R.ActionEnd{}),id)),work(w,rest),stack,actor,False{},answer))

def currentDrain(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> {Steps.iterate(Queue.cost(after(w,actor,values,rest,stack,incoming,rejected),work(w,rest),stack,currentQueue(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known)),after(w,actor,values,rest,stack,incoming,rejected)) == C.Machine{Queue.world(after(w,actor,values,rest,stack,incoming,rejected),work(w,rest),stack,currentQueue(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known)),work(w,rest),stack} : C.Machine}:
  Queue.drain(after(w,actor,values,rest,stack,incoming,rejected),work(w,rest),stack,currentQueue(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known),Debt.healthy(Resume.start(w,actor,rest,stack,incoming,rejected),1n+Eval.cost(values),id,offset,remaining,DebtBody.current(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known)))

def freshExact(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Source.flush(Cache.canonical(w,id,1n+offset),1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> {after(w,actor,values,rest,stack,incoming,rejected) == Body.done(Entry.prepared(w,actor,R.ActionEnd{}),values,id,answer,actor,work(w,rest),stack) : C.Machine}:
  +prepared = Entry.prepared(w,actor,R.ActionEnd{})
  +start = Body.start(prepared,values,id,answer,actor,work(w,rest),stack)
  +evaluated = bodyExact(prepared,values,id,answer,actor,work(w,rest),stack,offset,DebtBody.freshPrepared(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known))
  Equal.trans(C.Machine,after(w,actor,values,rest,stack,incoming,rejected),Steps.iterate(1n+Eval.cost(values),start),Body.done(Entry.prepared(w,actor,R.ActionEnd{}),values,id,answer,actor,work(w,rest),stack),Equal.cong(C.Machine,C.Machine,m=>Steps.iterate(1n+Eval.cost(values),m),Resume.start(w,actor,rest,stack,incoming,rejected),start,Resume.first(w,actor,values,id,answer,rest,stack,incoming,rejected,known)),evaluated)

def freshQueue(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Source.flush(Cache.canonical(w,id,1n+offset),1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> Queue.Queue<after(w,actor,values,rest,stack,incoming,rejected),work(w,rest),stack>:
  Queue.substitute(Body.done(Entry.prepared(w,actor,R.ActionEnd{}),values,id,answer,actor,work(w,rest),stack),after(w,actor,values,rest,stack,incoming,rejected),work(w,rest),stack,Equal.sym(C.Machine,after(w,actor,values,rest,stack,incoming,rejected),Body.done(Entry.prepared(w,actor,R.ActionEnd{}),values,id,answer,actor,work(w,rest),stack),freshExact(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known)),Queue.done(A.exit(History.run(values,Entry.prepared(w,actor,R.ActionEnd{}),id)),work(w,rest),stack,actor,False{},answer))

def freshDrain(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Source.flush(Cache.canonical(w,id,1n+offset),1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> {Steps.iterate(Queue.cost(after(w,actor,values,rest,stack,incoming,rejected),work(w,rest),stack,freshQueue(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known)),after(w,actor,values,rest,stack,incoming,rejected)) == C.Machine{Queue.world(after(w,actor,values,rest,stack,incoming,rejected),work(w,rest),stack,freshQueue(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known)),work(w,rest),stack} : C.Machine}:
  Queue.drain(after(w,actor,values,rest,stack,incoming,rejected),work(w,rest),stack,freshQueue(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known),Debt.healthy(Resume.start(w,actor,rest,stack,incoming,rejected),1n+Eval.cost(values),id,offset,remaining,DebtBody.fresh(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known)))
