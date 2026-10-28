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

def fromBody(+before: C.Machine,+steps: Nat,+body: R.World,+values: List<&2,R.Value>,+id: Nat,+offset: Nat,+remaining: Nat,input: BodyInput.Input<body,id,offset>,same: {Output.outer(C.world(Steps.iterate(steps,before))) == Output.outer(Exit.target(History.run(values,body,id),1n+offset,remaining)) : R.World}) -> Debt.Outcome<before,steps,id,offset,remaining>:
  +evidence = {Debt.Written{before,steps,History.run(values,body,id),BodyInput.written(values,body,id,offset,input),same} : Debt.Evidence<id,offset,remaining>}
  Debt.At{evidence,{==},{==}}

def currentPrepared(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> BodyInput.Input<Entry.prepared(w,actor,R.ActionEnd{}),id,offset>:
  +root = {1n+offset : Nat}
  +source = Prepare.current(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive,CachePrep.future(w,id,offset,initial),CachePrep.stopped(w,id,offset,initial))
  +extension = Transfer.sameExtension(w,Entry.prepared(w,actor,R.ActionEnd{}),id,source)
  +arena = Prepare.currentArena(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive,CachePrep.future(w,id,offset,initial),CachePrep.stopped(w,id,offset,initial))
  +moved = Move.moveAlias(w,Entry.prepared(w,actor,R.ActionEnd{}),root,sourceAlias,Move.fullArena(w,Entry.prepared(w,actor,R.ActionEnd{}),arena))
  BodyInput.Prepared{Move.aliasValue(w,Entry.prepared(w,actor,R.ActionEnd{}),root,sourceAlias,moved),SourceResume.sourceCapture(w,Entry.prepared(w,actor,R.ActionEnd{}),id,root,sourceAlias,cached,extension,moved),CachePrep.current(w,id,actor,offset,captureOffset,R.ActionEnd{},initial,alias,captured,positive)}


def current(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> Debt.Outcome<Resume.start(w,actor,rest,stack,incoming,rejected),1n+Eval.cost(values),id,offset,remaining>:
  fromBody(Resume.start(w,actor,rest,stack,incoming,rejected),1n+Eval.cost(values),Entry.prepared(w,actor,R.ActionEnd{}),values,id,offset,remaining,currentPrepared(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known),SourceResume.current(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known))

def freshPrepared(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Source.flush(Cache.canonical(w,id,1n+offset),1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> BodyInput.Input<Entry.prepared(w,actor,R.ActionEnd{}),id,offset>:
  +root = {1n+offset : Nat}
  +source = Prepare.fresh(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive,empty)
  +selected = Source.flush(w,root)
  +extension = Equal.trans(R.NodeExtension,B.extension(Entry.prepared(w,actor,R.ActionEnd{}),id),B.extension(selected,id),B.extension(w,id),Transfer.sameExtension(selected,Entry.prepared(w,actor,R.ActionEnd{}),id,source),SourceResume.flushExtension(w,root,id))
  +arena = Prepare.freshArena(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive,empty)
  +moved = Move.moveAlias(w,Entry.prepared(w,actor,R.ActionEnd{}),root,sourceAlias,Move.fullArena(w,Entry.prepared(w,actor,R.ActionEnd{}),arena))
  BodyInput.Prepared{Move.aliasValue(w,Entry.prepared(w,actor,R.ActionEnd{}),root,sourceAlias,moved),SourceResume.sourceCapture(w,Entry.prepared(w,actor,R.ActionEnd{}),id,root,sourceAlias,cached,extension,moved),CachePrep.fresh(w,id,actor,offset,captureOffset,R.ActionEnd{},initial,alias,captured,positive,empty)}


def fresh(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Source.flush(Cache.canonical(w,id,1n+offset),1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> Debt.Outcome<Resume.start(w,actor,rest,stack,incoming,rejected),1n+Eval.cost(values),id,offset,remaining>:
  fromBody(Resume.start(w,actor,rest,stack,incoming,rejected),1n+Eval.cost(values),Entry.prepared(w,actor,R.ActionEnd{}),values,id,offset,remaining,freshPrepared(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known),SourceResume.fresh(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known))
