# Actual source-cache redirect resolution before comparison. Canonical is an
# initial field observation, not a substituted runtime setter or supplied result.
import Base
import ./held-write-history.bend as History
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/write.bend as W
import ../runtime/constants.bend as K
import ./transaction-rejoin-history.bend as Alias
import ./held-setter-entry.bend as Entry
import ./held-write-profile.bend as P
import ./held-setter-frames.bend as Setter
import ./setter-committed-frame.bend as Compare

def canonical(+w: R.World,+id: Nat,root: Nat) -> R.World:
  B.store_extension(w,id,R.NodeExtension.with_transaction(B.extension(w,id),root))

def arena(+w: R.World,+id: Nat,+root: Nat) -> {R.World.txArena(canonical(w,id,root)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def node(+w: R.World,+id: Nat,+root: Nat,+reader: Nat) -> {B.node(canonical(w,id,root),reader) == B.node(w,reader) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def future(+w: R.World,+id: Nat,+root: Nat) -> {R.World.flushTransaction(canonical(w,id,root)) == R.World.flushTransaction(w) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def txOf(+w: R.World,+id: Nat,+root: Nat,+alias: Alias.Alias<w,root>,cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,root,alias) : Nat}) -> {X.txOf(w,id) == B.Bundle{canonical(w,id,root),root} : B.Bundle<R.World,Nat>}:
  Equal.cong(B.Bundle<R.World,Nat>,B.Bundle<R.World,Nat>,pair=>Entry.unpack(pair,id),X.resolveTx(w,R.NodeExtension.transaction(B.extension(w,id))),B.Bundle{w,root},Equal.trans(B.Bundle<R.World,Nat>,X.resolveTx(w,R.NodeExtension.transaction(B.extension(w,id))),X.resolveTx(w,Alias.identity(w,root,alias)),B.Bundle{w,root},Equal.cong(Nat,B.Bundle<R.World,Nat>,n=>X.resolveTx(w,n),R.NodeExtension.transaction(B.extension(w,id)),Alias.identity(w,root,alias),cached),Alias.resolution(w,root,alias)))

def join(+w: R.World,+id: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<canonical(w,id,1n+offset),id,offset>) -> {X.joinNode(w,id) == Entry.scheduled(canonical(w,id,1n+offset)) : R.World}:
  +root = {1n+offset : Nat}
  +next = canonical(w,id,root)
  Equal.trans(R.World,X.joinNode(w,id),X.joinFuture(next,root),Entry.scheduled(next),Equal.cong(B.Bundle<R.World,Nat>,R.World,pair=>X.joinFuture(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair)),X.txOf(w,id),B.Bundle{next,root},txOf(w,id,root,alias,cached)),Entry.joinFuture(next,offset,P.future(next,id,offset,profile),P.terminal(next,id,offset,profile)))

def held(-w: R.World,-id: Nat,-offset: Nat,profile: P.Profile<w,id,offset>) -> {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == True{} : Bool}:
  match profile:
    case P.HeldAt{path,extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}: held

def before(+w: R.World,+id: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<canonical(w,id,1n+offset),id,offset>) -> {W.beforeCompare(w,id) == Entry.scheduled(canonical(w,id,1n+offset)) : R.World}:
  +next = canonical(w,id,1n+offset)
  +heldInitial = Equal.trans(Bool,B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),B.has(R.Node.config(B.node(next,id)),K.CONFIG_HELD()),True{},Equal.cong(R.Node,Bool,n=>B.has(R.Node.config(n),K.CONFIG_HELD()),B.node(w,id),B.node(next,id),Equal.sym(R.Node,B.node(next,id),B.node(w,id),node(w,id,1n+offset,id))),held(next,id,offset,profile))
  Equal.trans(R.World,W.beforeCompare(w,id),X.joinNode(w,id),Entry.scheduled(next),Equal.cong(Bool,R.World,flag=>B.choose(~R.World,flag,_=>X.joinNode(w,id),_=>w),B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),True{},heldInitial),join(w,id,offset,alias,cached,profile))

def setter(+w: R.World,+id: Nat,+offset: Nat,+value: R.Value,+alias: Alias.Alias<w,1n+offset>,cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<canonical(w,id,1n+offset),id,offset>) -> {W.setSignal(w,id,value) == W.setSignal(canonical(w,id,1n+offset),id,value) : R.World}:
  +next = canonical(w,id,1n+offset)
  +scheduled = Entry.scheduled(next)
  +current = B.current(B.node(w,id))
  Equal.trans(R.World,W.setSignal(w,id,value),Compare.compared(scheduled,id,current,value),W.setSignal(next,id,value),Equal.cong(R.World,R.World,state=>Compare.compared(state,id,current,value),W.beforeCompare(w,id),scheduled,before(w,id,offset,alias,cached,profile)),Equal.trans(R.World,Compare.compared(scheduled,id,current,value),Compare.compared(scheduled,id,B.current(B.node(next,id)),value),W.setSignal(next,id,value),Equal.cong(R.Node,R.World,n=>Compare.compared(scheduled,id,B.current(n),value),B.node(w,id),B.node(next,id),Equal.sym(R.Node,B.node(next,id),B.node(w,id),node(w,id,1n+offset,id))),Equal.sym(R.World,W.setSignal(next,id,value),Compare.compared(scheduled,id,B.current(B.node(next,id)),value),Equal.cong(R.World,R.World,state=>Compare.compared(state,id,B.current(B.node(next,id)),value),W.beforeCompare(next,id),scheduled,Setter.beforeExact(next,id,offset,profile)))))

def resolved(+w: R.World,+id: Nat,+offset: Nat,+current: R.Value,+value: R.Value,+alias: Alias.Alias<w,1n+offset>,cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<canonical(w,id,1n+offset),id,offset>) -> {W.setResolved(w,id,current,value) == W.setResolved(canonical(w,id,1n+offset),id,current,value) : R.World}:
  +next = canonical(w,id,1n+offset)
  +scheduled = Entry.scheduled(next)
  Equal.trans(R.World,W.setResolved(w,id,current,value),Compare.compared(scheduled,id,current,value),W.setResolved(next,id,current,value),Equal.cong(R.World,R.World,state=>Compare.compared(state,id,current,value),W.beforeCompare(w,id),scheduled,before(w,id,offset,alias,cached,profile)),Equal.sym(R.World,W.setResolved(next,id,current,value),Compare.compared(scheduled,id,current,value),Equal.cong(R.World,R.World,state=>Compare.compared(state,id,current,value),W.beforeCompare(next,id),scheduled,Setter.beforeExact(next,id,offset,profile))))

def substitute(-a: R.World,-b: R.World,-id: Nat,-offset: Nat,same: {a == b : R.World},profile: P.Profile<a,id,offset>) -> P.Profile<b,id,offset>:
  %same : P.Profile<_,id,offset>
  profile

def successor(+w: R.World,+id: Nat,+offset: Nat,+value: R.Value,+alias: Alias.Alias<w,1n+offset>,cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<canonical(w,id,1n+offset),id,offset>) -> P.Profile<W.setSignal(w,id,value),id,offset>:
  +next = canonical(w,id,1n+offset)
  substitute(W.setSignal(next,id,value),W.setSignal(w,id,value),id,offset,Equal.sym(R.World,W.setSignal(w,id,value),W.setSignal(next,id,value),setter(w,id,offset,value,alias,cached,profile)),Setter.next(next,id,value,offset,profile))

def history(+w: R.World,+id: Nat,+offset: Nat,+head: R.Value,+tail: List<&2,R.Value>,+alias: Alias.Alias<w,1n+offset>,cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},profile: P.Profile<canonical(w,id,1n+offset),id,offset>) -> {History.run(head <> tail,w,id) == History.run(head <> tail,canonical(w,id,1n+offset),id) : R.World}:
  Equal.cong(R.World,R.World,next=>History.run(tail,next,id),W.setSignal(w,id,head),W.setSignal(canonical(w,id,1n+offset),id,head),setter(w,id,offset,head,alias,cached,profile))
