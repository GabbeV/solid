# Actual captured resume with independent source-cache and actor-capture aliases.
# Preparation derives the virtual body certificate and moves both routes. Empty
# bodies retain the cache. Public construction and publication remain separate.
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

def through(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+remaining: Nat,+profile: P.Profile<Cache.canonical(Entry.prepared(w,actor,R.ActionEnd{}),id,1n+offset),id,offset>,+sourceAlias: Alias.Alias<Entry.prepared(w,actor,R.ActionEnd{}),1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(Entry.prepared(w,actor,R.ActionEnd{}),id)) == Alias.identity(Entry.prepared(w,actor,R.ActionEnd{}),1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(Entry.prepared(w,actor,R.ActionEnd{}),actor)) == Alias.identity(w,1n+offset,alias) : Nat},+arena: {R.World.txArena(Entry.prepared(w,actor,R.ActionEnd{})) == R.World.txArena(w) : List<&2,R.Transaction>},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr},moved: Move.AliasRebased<w,Entry.prepared(w,actor,R.ActionEnd{}),1n+offset,alias>) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Resume.start(w,actor,rest,stack,incoming,rejected)))) == Output.outer(Exit.target(History.run(values,Entry.prepared(w,actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}:
  match moved:
    case Move.AliasAt{value,identity}:
      match value:
        case Alias.Alias{+path,+extra,room,+atRoot}:
          +next = Entry.prepared(w,actor,R.ActionEnd{})
          +root = {1n+offset : Nat}
          +work = {C.ActionSliceEnd{R.World.question(w)} <> rest : List<&2,C.Task>}
          +captureAtPath = Equal.trans(Nat,R.ActionState.transaction(A.get(next,actor)),Alias.identity(w,root,alias),Path.origin(next,path),captured,Equal.sym(Nat,Path.origin(next,path),Alias.identity(w,root,alias),identity))
          +nextOpen = Equal.trans(Nat,R.Transaction.open(B.transaction(next,root)),R.Transaction.open(B.transaction(w,root)),1n+remaining,Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.open(B.get(R.Transaction,rows,root,B.blank_transaction())),R.World.txArena(next),R.World.txArena(w),arena),open)
          +openAtPath = Equal.trans(Nat,R.Transaction.open(B.transaction(next,Path.terminal(next,path))),R.Transaction.open(B.transaction(next,root)),1n+remaining,Equal.cong(Nat,Nat,group=>R.Transaction.open(B.transaction(next,group)),Path.terminal(next,path),root,atRoot),nextOpen)
          +body = Retire.retire(values,next,id,answer,actor,work,stack,offset,sourceAlias,cached,profile,path,extra,remaining,captureAtPath,room,openAtPath)
          +retired = Equal.trans(R.World,Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(next,values,id,answer,actor,work,stack)))),Output.outer(Exit.target(History.run(values,next,id),Path.terminal(next,path),remaining)),Output.outer(Exit.target(History.run(values,next,id),root,remaining)),body,Equal.cong(Nat,R.World,group=>Output.outer(Exit.target(History.run(values,next,id),group,remaining)),Path.terminal(next,path),root,atRoot))
          Equal.trans(R.World,Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Resume.start(w,actor,rest,stack,incoming,rejected)))),Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(next,values,id,answer,actor,work,stack)))),Output.outer(Exit.target(History.run(values,next,id),root,remaining)),Equal.cong(C.Machine,R.World,m=>Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),m))),Resume.start(w,actor,rest,stack,incoming,rejected),Body.start(next,values,id,answer,actor,work,stack),Resume.first(w,actor,values,id,answer,rest,stack,incoming,rejected,known)),retired)

def flushExtension(+w: R.World,+root: Nat,+id: Nat) -> {B.extension(Source.flush(w,root),id) == B.extension(w,id) : R.NodeExtension}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sourceCapture(+w: R.World,+next: R.World,+id: Nat,+root: Nat,+sourceAlias: Alias.Alias<w,root>,cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,root,sourceAlias) : Nat},extension: {B.extension(next,id) == B.extension(w,id) : R.NodeExtension},+moved: Move.AliasRebased<w,next,root,sourceAlias>) -> {R.NodeExtension.transaction(B.extension(next,id)) == Alias.identity(next,root,Move.aliasValue(w,next,root,sourceAlias,moved)) : Nat}:
  Equal.trans(Nat,R.NodeExtension.transaction(B.extension(next,id)),R.NodeExtension.transaction(B.extension(w,id)),Alias.identity(next,root,Move.aliasValue(w,next,root,sourceAlias,moved)),Equal.cong(R.NodeExtension,Nat,record=>R.NodeExtension.transaction(record),B.extension(next,id),B.extension(w,id),extension),Equal.trans(Nat,R.NodeExtension.transaction(B.extension(w,id)),Alias.identity(w,root,sourceAlias),Alias.identity(next,root,Move.aliasValue(w,next,root,sourceAlias,moved)),cached,Equal.sym(Nat,Alias.identity(next,root,Move.aliasValue(w,next,root,sourceAlias,moved)),Alias.identity(w,root,sourceAlias),Move.aliasIdentity(w,next,root,sourceAlias,moved))))

def current(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Resume.start(w,actor,rest,stack,incoming,rejected)))) == Output.outer(Exit.target(History.run(values,Entry.prepared(w,actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}:
  +root = {1n+offset : Nat}
  +next = Entry.prepared(w,actor,R.ActionEnd{})
  +source = Prepare.current(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive,CachePrep.future(w,id,offset,initial),CachePrep.stopped(w,id,offset,initial))
  +extension = Transfer.sameExtension(w,next,id,source)
  +arena = Prepare.currentArena(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive,CachePrep.future(w,id,offset,initial),CachePrep.stopped(w,id,offset,initial))
  +moved = Move.moveAlias(w,next,root,sourceAlias,Move.fullArena(w,next,arena))
  through(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,remaining,CachePrep.current(w,id,actor,offset,captureOffset,R.ActionEnd{},initial,alias,captured,positive),Move.aliasValue(w,next,root,sourceAlias,moved),sourceCapture(w,next,id,root,sourceAlias,cached,extension,moved),alias,Input.capture(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive),arena,open,known,Move.moveAlias(w,next,root,alias,Move.fullArena(w,next,arena)))

def fresh(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Source.flush(Cache.canonical(w,id,1n+offset),1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Resume.start(w,actor,rest,stack,incoming,rejected)))) == Output.outer(Exit.target(History.run(values,Entry.prepared(w,actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}:
  +root = {1n+offset : Nat}
  +next = Entry.prepared(w,actor,R.ActionEnd{})
  +source = Prepare.fresh(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive,empty)
  +selected = Source.flush(w,root)
  +extension = Equal.trans(R.NodeExtension,B.extension(next,id),B.extension(selected,id),B.extension(w,id),Transfer.sameExtension(selected,next,id,source),flushExtension(w,root,id))
  +arena = Prepare.freshArena(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive,empty)
  +moved = Move.moveAlias(w,next,root,sourceAlias,Move.fullArena(w,next,arena))
  through(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,remaining,CachePrep.fresh(w,id,actor,offset,captureOffset,R.ActionEnd{},initial,alias,captured,positive,empty),Move.aliasValue(w,next,root,sourceAlias,moved),sourceCapture(w,next,id,root,sourceAlias,cached,extension,moved),alias,Input.capture(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive),arena,open,known,Move.moveAlias(w,next,root,alias,Move.fullArena(w,next,arena)))

def savedStack(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+remaining: Nat,+profile: P.Profile<Cache.canonical(Entry.prepared(w,actor,R.ActionEnd{}),id,1n+offset),id,offset>,+sourceAlias: Alias.Alias<Entry.prepared(w,actor,R.ActionEnd{}),1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(Entry.prepared(w,actor,R.ActionEnd{}),id)) == Alias.identity(Entry.prepared(w,actor,R.ActionEnd{}),1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(Entry.prepared(w,actor,R.ActionEnd{}),actor)) == Alias.identity(w,1n+offset,alias) : Nat},+arena: {R.World.txArena(Entry.prepared(w,actor,R.ActionEnd{})) == R.World.txArena(w) : List<&2,R.Transaction>},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr},moved: Move.AliasRebased<w,Entry.prepared(w,actor,R.ActionEnd{}),1n+offset,alias>) -> {C.values(Steps.iterate(1n+Eval.cost(values),Resume.start(w,actor,rest,stack,incoming,rejected))) == stack : List<&2,R.Value>}:
  +next = Entry.prepared(w,actor,R.ActionEnd{})
  +work = {C.ActionSliceEnd{R.World.question(w)} <> rest : List<&2,C.Task>}
  Equal.trans(List<&2,R.Value>,C.values(Steps.iterate(1n+Eval.cost(values),Resume.start(w,actor,rest,stack,incoming,rejected))),C.values(Steps.iterate(1n+Eval.cost(values),Body.start(next,values,id,answer,actor,work,stack))),stack,Equal.cong(C.Machine,List<&2,R.Value>,m=>C.values(Steps.iterate(1n+Eval.cost(values),m)),Resume.start(w,actor,rest,stack,incoming,rejected),Body.start(next,values,id,answer,actor,work,stack),Resume.first(w,actor,values,id,answer,rest,stack,incoming,rejected,known)),Retire.savedStack(values,next,id,answer,actor,work,stack,offset,sourceAlias,cached,profile))

def currentStack(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> {C.values(Steps.iterate(1n+Eval.cost(values),Resume.start(w,actor,rest,stack,incoming,rejected))) == stack : List<&2,R.Value>}:
  +root = {1n+offset : Nat}
  +next = Entry.prepared(w,actor,R.ActionEnd{})
  +source = Prepare.current(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive,CachePrep.future(w,id,offset,initial),CachePrep.stopped(w,id,offset,initial))
  +extension = Transfer.sameExtension(w,next,id,source)
  +arena = Prepare.currentArena(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive,CachePrep.future(w,id,offset,initial),CachePrep.stopped(w,id,offset,initial))
  +moved = Move.moveAlias(w,next,root,sourceAlias,Move.fullArena(w,next,arena))
  savedStack(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,remaining,CachePrep.current(w,id,actor,offset,captureOffset,R.ActionEnd{},initial,alias,captured,positive),Move.aliasValue(w,next,root,sourceAlias,moved),sourceCapture(w,next,id,root,sourceAlias,cached,extension,moved),alias,Input.capture(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive),arena,open,known,Move.moveAlias(w,next,root,alias,Move.fullArena(w,next,arena)))

def freshStack(+w: R.World,+actor: Nat,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+offset: Nat,+captureOffset: Nat,+remaining: Nat,+initial: P.Profile<Source.flush(Cache.canonical(w,id,1n+offset),1n+offset),id,offset>,+sourceAlias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,sourceAlias) : Nat},+alias: Alias.Alias<w,1n+offset>,+captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},+empty: {R.World.flushTransaction(w) == 0n : Nat},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},known: {R.ActionState.methods(A.get(w,actor)) == Resume.methods(values,id,answer) : R.Expr}) -> {C.values(Steps.iterate(1n+Eval.cost(values),Resume.start(w,actor,rest,stack,incoming,rejected))) == stack : List<&2,R.Value>}:
  +root = {1n+offset : Nat}
  +next = Entry.prepared(w,actor,R.ActionEnd{})
  +source = Prepare.fresh(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive,empty)
  +selected = Source.flush(w,root)
  +extension = Equal.trans(R.NodeExtension,B.extension(next,id),B.extension(selected,id),B.extension(w,id),Transfer.sameExtension(selected,next,id,source),flushExtension(w,root,id))
  +arena = Prepare.freshArena(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive,empty)
  +moved = Move.moveAlias(w,next,root,sourceAlias,Move.fullArena(w,next,arena))
  savedStack(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,remaining,CachePrep.fresh(w,id,actor,offset,captureOffset,R.ActionEnd{},initial,alias,captured,positive,empty),Move.aliasValue(w,next,root,sourceAlias,moved),sourceCapture(w,next,id,root,sourceAlias,cached,extension,moved),alias,Input.capture(w,actor,offset,captureOffset,R.ActionEnd{},alias,captured,positive),arena,open,known,Move.moveAlias(w,next,root,alias,Move.fullArena(w,next,arena)))
